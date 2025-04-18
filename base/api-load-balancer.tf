resource "kubernetes_service" "LoadBalancer" {
  depends_on = [ aws_eks_cluster.cluster, aws_eks_node_group.node-group, aws_eks_access_entry.access-entry, aws_eks_access_policy_association.eks-policy, aws_security_group.sg_snap, data.aws_eks_cluster_auth.default ]
  metadata {
    name = "load-balancer-api-videos"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
    }
  }
  spec {
    selector = {
      app = "api-videos-pod"
    }
    port {
      port = 8080
      target_port = 8080
    }
    type = "LoadBalancer"
  }
}

# Create a local variable for the load balancer name.
locals {
  depends_on = [ kubernetes_service.LoadBalancer, time_sleep.wait_5_minutes ]
  lb_name = split("-", split(".", kubernetes_service.LoadBalancer.status.0.load_balancer.0.ingress.0.hostname).0).0
}

# Read information about the load balancer using the AWS provider.
# wait 5 minutes, for the k8s load balancer to be ready
resource "time_sleep" "wait_5_minutes" {
  depends_on = [kubernetes_service.LoadBalancer]
  create_duration = "300s" # 300 seconds = 5 minutes
}

data "aws_lb" "LoadBalancer" {
  depends_on = [time_sleep.wait_5_minutes]
  name       = local.lb_name
}
