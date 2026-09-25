#!/usr/bin/env bash
# Post-apply bootstrap: create/verify MySQL user `app3` via SSM SendCommand (not bastion).
#
# Standard lab workflow (from infrastructure/):
#   terraform apply -var-file=secrets.tfvars
#   ./ops/phase-a-create-app3-user.sh
#
# Default (AUTO): wait for an SSM-online App3 instance → CREATE USER via SendCommand →
# optional ASG instance refresh so App3 userdata reconnects as app3.
#
# Interactive (no passwords in SSM command history):
#   INTERACTIVE=1 ./ops/phase-a-create-app3-user.sh
#
# Skip refresh after create (if you will refresh yourself):
#   REFRESH=0 ./ops/phase-a-create-app3-user.sh
#
# Lab note: AUTO mode may leave dbadmin/app3 passwords in SSM Run Command history.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SECRETS_FILE="${SECRETS_FILE:-secrets.tfvars}"
SQL_TEMPLATE="${SQL_TEMPLATE:-ops/phase-a-create-app3-user.sql}"
AWS_REGION="${AWS_REGION:-$(grep -E '^[[:space:]]*aws_region[[:space:]]*=' terraform.tfvars 2>/dev/null | sed -E 's/.*=[[:space:]]*\"?([^\"]+)\"?.*/\1/' || true)}"
AWS_REGION="${AWS_REGION:-us-east-1}"
export AWS_DEFAULT_REGION="$AWS_REGION"

# Default = automated post-apply path. Set INTERACTIVE=1 for manual SSM session.
INTERACTIVE="${INTERACTIVE:-0}"
# After CREATE USER, roll ASG instances so userdata can connect as app3.
REFRESH="${REFRESH:-1}"
WAIT_SECONDS="${WAIT_SECONDS:-600}"
WAIT_INTERVAL="${WAIT_INTERVAL:-15}"

if [[ ! -f "$SECRETS_FILE" ]]; then
  echo "Missing $SECRETS_FILE" >&2
  exit 1
fi
if [[ ! -f "$SQL_TEMPLATE" ]]; then
  echo "Missing $SQL_TEMPLATE" >&2
  exit 1
fi

tfvar() {
  local key="$1"
  local line
  line="$(grep -E "^[[:space:]]*${key}[[:space:]]*=" "$SECRETS_FILE" | tail -n1)" || true
  if [[ -z "$line" ]]; then
    echo "Missing ${key} in ${SECRETS_FILE}" >&2
    exit 1
  fi
  echo "$line" | sed -E "s/^[^=]+=[[:space:]]*//; s/^\"//; s/\"[[:space:]]*$//; s/^'//; s/'[[:space:]]*$//"
}

echo "Reading Terraform outputs..."
DB_HOST="$(terraform output -raw db_instance_address)"

ASG_NAME=""
if ASG_NAME="$(terraform output -raw app3_asg_name 2>/dev/null)"; then
  :
else
  ASG_NAME=""
fi

resolve_instance_id() {
  local id=""
  if [[ -n "$ASG_NAME" ]]; then
    id="$(aws autoscaling describe-auto-scaling-groups \
      --auto-scaling-group-names "$ASG_NAME" \
      --query 'AutoScalingGroups[0].Instances[?LifecycleState==`InService`].InstanceId | [0]' \
      --output text 2>/dev/null || true)"
    if [[ -z "$id" || "$id" == "None" ]]; then
      id=""
    fi
  fi
  if [[ -z "$id" ]]; then
    if terraform output -json app3_ec2_private_instance_ids >/dev/null 2>&1; then
      id="$(terraform output -json app3_ec2_private_instance_ids | python3 -c 'import json,sys; v=json.load(sys.stdin); print(v[0] if isinstance(v,list) and v else (list(v.values())[0] if v else ""))')"
    fi
  fi
  if [[ -z "$id" || "$id" == "None" ]]; then
    echo ""
  else
    echo "$id"
  fi
}

ssm_online() {
  local id="$1"
  local ping
  ping="$(aws ssm describe-instance-information \
    --filters "Key=InstanceIds,Values=${id}" \
    --query 'InstanceInformationList[0].PingStatus' \
    --output text 2>/dev/null || true)"
  [[ "$ping" == "Online" ]]
}

echo "Waiting up to ${WAIT_SECONDS}s for an App3 instance that is InService and SSM Online..."
INSTANCE_ID=""
elapsed=0
while (( elapsed < WAIT_SECONDS )); do
  INSTANCE_ID="$(resolve_instance_id)"
  if [[ -n "$INSTANCE_ID" ]] && ssm_online "$INSTANCE_ID"; then
    echo "Using App3 instance ${INSTANCE_ID}"
    break
  fi
  if [[ -n "$INSTANCE_ID" ]]; then
    echo "  … ${INSTANCE_ID} not SSM Online yet (${elapsed}s)"
  else
    echo "  … no InService App3 instance yet (${elapsed}s)"
  fi
  sleep "$WAIT_INTERVAL"
  elapsed=$((elapsed + WAIT_INTERVAL))
  INSTANCE_ID=""
done

if [[ -z "$INSTANCE_ID" ]]; then
  echo "Timed out waiting for App3 + SSM. Check ASG, IAM instance profile, and NAT." >&2
  exit 1
fi

DB_ADMIN_PASSWORD="$(tfvar db_password)"
APP3_PASSWORD="$(tfvar app3_db_password)"

SQL_PASSWORD_ESCAPED="${APP3_PASSWORD//\'/\'\'}"
TMP_SQL="$(mktemp)"
trap 'rm -f "$TMP_SQL"' EXIT
sed "s/APP3_DB_PASSWORD/${SQL_PASSWORD_ESCAPED}/g" "$SQL_TEMPLATE" > "$TMP_SQL"

if [[ "$INTERACTIVE" == "1" ]]; then
  cat <<EOF
========================================================================
Interactive mode (INTERACTIVE=1)
========================================================================
1) Start Session Manager on App3:
     aws ssm start-session --target ${INSTANCE_ID} --region ${AWS_REGION}

2) On the instance, install a client if needed, then run mysql as dbadmin:
     sudo yum install -y mariadb || true
     mysql -h ${DB_HOST} -u dbadmin -p

3) Paste the SQL from: ${SQL_TEMPLATE}
   Use the SAME password as secrets.tfvars app3_db_password
   (filled copy prepared locally at: ${TMP_SQL} — do not commit it)

4) Verify:
     mysql -h ${DB_HOST} -u app3 -p webappdb

5) Refresh App3 so userdata reconnects (if instances booted before this user existed):
     aws autoscaling start-instance-refresh --auto-scaling-group-name ${ASG_NAME:-<app3-asg-name>}

Filled SQL is also printed below (contains secrets — clear your terminal after).
------------------------------------------------------------------------
EOF
  cat "$TMP_SQL"
  echo "------------------------------------------------------------------------"
  exit 0
fi

echo "AUTO: creating MySQL user app3 via SSM SendCommand on ${INSTANCE_ID}..."
REMOTE_SCRIPT="$(mktemp)"
trap 'rm -f "$TMP_SQL" "$REMOTE_SCRIPT"' EXIT

cat > "$REMOTE_SCRIPT" <<REMOTE
set -euo pipefail
if ! command -v mysql >/dev/null 2>&1; then
  sudo yum install -y mariadb || sudo yum install -y mysql || true
fi
mysql -h '${DB_HOST}' -u dbadmin -p'${DB_ADMIN_PASSWORD}' <<'EOSQL'
$(cat "$TMP_SQL")
EOSQL
mysql -h '${DB_HOST}' -u app3 -p'${APP3_PASSWORD}' webappdb -e "SELECT CURRENT_USER() AS me, DATABASE() AS dbname;"
REMOTE

# Use a full JSON parameters object so newlines survive (shorthand commands=[...]
# leaves literal \n and breaks the mysql heredoc on the instance).
SSM_PARAMS="$(python3 -c 'import json,sys; print(json.dumps({"commands": [open(sys.argv[1]).read()]}))' "$REMOTE_SCRIPT")"
COMMAND_ID="$(aws ssm send-command \
  --instance-ids "$INSTANCE_ID" \
  --document-name "AWS-RunShellScript" \
  --comment "Create MySQL app3 user (post-apply bootstrap)" \
  --parameters "$SSM_PARAMS" \
  --query 'Command.CommandId' \
  --output text)"

echo "Waiting for CommandId ${COMMAND_ID}..."
aws ssm wait command-executed --command-id "$COMMAND_ID" --instance-id "$INSTANCE_ID" || true
STATUS="$(aws ssm get-command-invocation --command-id "$COMMAND_ID" --instance-id "$INSTANCE_ID" --query 'Status' --output text)"
echo "SendCommand status: ${STATUS}"
if [[ "$STATUS" != "Success" ]]; then
  aws ssm get-command-invocation --command-id "$COMMAND_ID" --instance-id "$INSTANCE_ID" --query 'StandardErrorContent' --output text >&2 || true
  exit 1
fi

echo "MySQL user app3 created/verified via SSM."

if [[ "$REFRESH" == "1" ]]; then
  if [[ -z "$ASG_NAME" ]]; then
    echo "REFRESH=1 but app3_asg_name output missing; skip instance refresh." >&2
  else
    echo "Starting ASG instance refresh on ${ASG_NAME} so App3 boots against user app3..."
    REFRESH_ID="$(aws autoscaling start-instance-refresh \
      --auto-scaling-group-name "$ASG_NAME" \
      --preferences MinHealthyPercentage=50,InstanceWarmup=120 \
      --query 'InstanceRefreshId' \
      --output text)"
    echo "Instance refresh started: ${REFRESH_ID}"
    echo "Wait until TG3 targets are healthy, then open https://<your-dns>/"
  fi
else
  echo "REFRESH=0: skip ASG refresh. Replace/refresh App3 yourself if UMS was unhealthy."
fi

echo "Done. Keep app3_db_password aligned with Parameter Store. Do not commit secrets."
