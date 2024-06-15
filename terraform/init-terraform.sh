# Ensure all necessary environment variables are set
: "${TF_VAR_bucket_name:?}"
: "${TF_VAR_bucket_key:?}"
: "${TF_VAR_bucket_region:?}"

# Create a backend configuration file from the environment variables
cat > backend.conf <<EOF
bucket     = "${TF_VAR_bucket_name}"
key        = "${TF_VAR_bucket_key}"
region     = "${TF_VAR_bucket_region}"
EOF

# Initialize Terraform with the backend configuration
terraform init -backend-config=backend.conf
