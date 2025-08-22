# Stacks (you’re already clean)
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE ROLLBACK_COMPLETE DELETE_FAILED \
  --query "StackSummaries[].StackName"

# EKS cluster & nodegroups
aws eks list-clusters --region ap-southeast-2
aws eks list-nodegroups --cluster-name demo-eks-dev --region ap-southeast-2 2>/dev/null || echo "No cluster"

# EC2 instances (should be [])
aws ec2 describe-instances \
  --filters "Name=tag:eks:cluster-name,Values=demo-eks-dev" \
  --region ap-southeast-2 \
  --query "Reservations[].Instances[].{Id:InstanceId,State:State.Name}"

# Classic & ALB/NLB load balancers (scan names; delete if clearly from this cluster)
aws elb describe-load-balancers --region ap-southeast-2 --query "LoadBalancerDescriptions[].LoadBalancerName"
aws elbv2 describe-load-balancers --region ap-southeast-2 --query "LoadBalancers[].LoadBalancerName"

# Orphaned EBS volumes (PVCs) that are available (not in-use)
aws ec2 describe-volumes --region ap-southeast-2 --filters Name=status,Values=available \
  --query "Volumes[].{Id:VolumeId,Tags:Tags}"

# ENIs that mention eks (usually harmless if 'in-use' is false)
aws ec2 describe-network-interfaces --region ap-southeast-2 \
  --filters Name=description,Values="*eks*" \
  --query "NetworkInterfaces[].{Id:NetworkInterfaceId,Status:Status,Desc:Description}"
