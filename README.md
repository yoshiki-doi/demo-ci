# demo-ci

Shared CI workflow for the `demo-biz-*` repositories (build, scan with Sysdig, push to ghcr.io).

```yaml
jobs:
  ci:
    permissions: {contents: read, packages: write, security-events: write}
    uses: Qfour/demo-ci/.github/workflows/build-scan-push.yml@main
    with:
      image-name: ghcr.io/qfour/demo-biz-a
      stop-on-failed-policy-eval: true   # fail the job (and skip the push) on a failed Sysdig policy
      upload-sarif: false                # needs code scanning (public repo or GitHub Code Security)
    secrets:
      SECURE_API_TOKEN: ${{ secrets.SECURE_API_TOKEN }}
```

## SARIF / code scanning

With `upload-sarif: true` the Sysdig report is uploaded to GitHub code scanning. To keep the alert list manageable:

| input | default | effect |
|---|---|---|
| `sarif-severity-at-least` | `high` | only report this severity and above |
| `sarif-group-by-package` | `true` | one alert per package instead of one per CVE |
| `sarif-exclude-accepted` | `true` | skip risks accepted in Sysdig |

These only shape the SARIF report; `stop-on-failed-policy-eval` still follows the Sysdig policy.
