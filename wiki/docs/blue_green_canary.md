## blue-green

- Create new `green` deployment with new app version / labels etc.
- Switch all traffic at once from `blue` version to `green` using labels on service

## canary

- Create new `canary` deployment with new app version / labels etc. - both must have labe lspecified in service selector
- Redirect small percentage of traffic to new version by reducing pod's number of new `canary` deployment(as k8s redirect them equaly)
- Switch `primary` deployment to newer version and delete `canary` deployment
