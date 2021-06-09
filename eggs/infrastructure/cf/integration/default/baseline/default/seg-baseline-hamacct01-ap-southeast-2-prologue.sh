#!/usr/bin/env bash
#--Hamlet-RequestReference=unassigned
#--Hamlet-ConfigurationReference=unassigned
#--Hamlet-RunId=kmxho4g51q
case ${STACK_OPERATION} in
  create|update)
create_pseudo_stack "Seed Values" "${CF_DIR}/$(fileBase "${BASH_SOURCE}")-seed-pseudo-stack.json" "seedXsegment" "kmxho4g51q" "Account" "598113632803" "Region" "ap-southeast-2" "DeploymentUnit" "baseline-prologue" "DeploymentMode" "update"  || return $?
       ;;
       esac
