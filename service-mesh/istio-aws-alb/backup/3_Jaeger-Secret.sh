JAEGER_USERNAME=$(echo -n "jaeger" | base64)
JAEGER_PASSPHRASE=$(echo -n "JaegerP@ssw0rd" | base64) # Replace JaegerP@ssw0rd with your password

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: jaeger
  namespace: istio-system
  labels:
    app: jaeger
type: Opaque
data:
  username: $JAEGER_USERNAME
  passphrase: $JAEGER_PASSPHRASE
EOF