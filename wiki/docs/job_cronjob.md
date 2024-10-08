## JOB

```yml
apiVersion: batch/v1
kind: Job
metadata:
  name: math-add-job
spec:
  template:
    spec:
      completions: 3  # How many pods have to finish with success - create as many as needed to complete 3 with success
      parallelism: 3
      containers:
      - name: math-add
        image: ubuntu
        command: ['expr', '3', '+', '2']
      restartPolicy: Never
```

## CRONJOB

```yml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: reort-cronjob
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      completions: 3
      parallelism: 3
      template:
        spec:
          containers:
          - name: report-tool
            image: report-tool
          restartPolicy: Never
```