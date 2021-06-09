#!/usr/bin/env bash
#--Hamlet-RequestReference=unassigned
#--Hamlet-ConfigurationReference=unassigned
#--Hamlet-RunId=kmxho4g51q
function manage_ssh_credentials() {
  info "Checking SSH credentials ..."
  #
  # Create SSH credential for the segment
  mkdir -p "${SEGMENT_OPERATIONS_DIR}"
  create_pki_credentials "${SEGMENT_OPERATIONS_DIR}" "ap-southeast-2" "hamacct01" ".aws-hamacct01-ap-southeast-2-ssh-crt.pem" ".aws-hamacct01-ap-southeast-2-ssh-prv.pem" || return $?
  #
  # Update the credential if required
  if ! check_ssh_credentials "ap-southeast-2" "${key_pair_name}"; then
    pem_file="${SEGMENT_OPERATIONS_DIR}/.aws-hamacct01-ap-southeast-2-ssh-crt.pem"
    update_ssh_credentials "ap-southeast-2" "${key_pair_name}" "${pem_file}" || return $?
    [[ -f "${SEGMENT_OPERATIONS_DIR}/.aws-hamacct01-ap-southeast-2-ssh-prv.pem.plaintext" ]] && 
      { encrypt_kms_file "ap-southeast-2" "${SEGMENT_OPERATIONS_DIR}/.aws-hamacct01-ap-southeast-2-ssh-prv.pem.plaintext" "${SEGMENT_OPERATIONS_DIR}/.aws-hamacct01-ap-southeast-2-ssh-prv.pem" "alias/eggs-integration-management-baseline-cmk" || return $?; }
  fi
  #
create_pseudo_stack "SSH Key Pair" "${CF_DIR}/$(fileBase "${BASH_SOURCE}")-keypair-pseudo-stack.json" "sshKeyPairXmgmtXbaselineXssh" "${key_pair_name}" "sshKeyPairXmgmtXbaselineXsshXname" "${key_pair_name}" "Account" "598113632803" "Region" "ap-southeast-2" "DeploymentUnit" "baseline-epilogue" "DeploymentMode" "update"  || return $?
  #
  show_ssh_credentials "ap-southeast-2" "${key_pair_name}"
  #
  return 0
}
#
# Determine the required key pair name
key_pair_name="eggs-integration-management-baseline-ssh"
#
case ${STACK_OPERATION} in
  delete)
    delete_ssh_credentials  "ap-southeast-2" "${key_pair_name}" || return $?
    delete_pki_credentials "${SEGMENT_OPERATIONS_DIR}" || return $?
    rm -f "${CF_DIR}/$(fileBase "${BASH_SOURCE}")-keypair-pseudo-stack.json"
    ;;
  create|update)
    manage_ssh_credentials || return $?
    ;;
 esac
