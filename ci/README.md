# CI notes

## Delete workflow runs
```
OWNER=
REPO=

# list workflow ids
gh api -X GET /repos/$OWNER/$REPO/actions/workflows | jq '.workflows[] | .name,.id'

WORKFLOW_ID=

# list runs
gh api -X GET /repos/$OWNER/$REPO/actions/workflows/$WORKFLOW_ID/runs | jq '.workflow_runs[] | .id' | tail -n 10

# delete oldest 10 workflows (won't delete the running one)
gh api -X GET /repos/$OWNER/$REPO/actions/workflows/$WORKFLOW_ID/runs | jq '.workflow_runs[] | .id' | tail -n 10 | xargs -I{} gh api -X DELETE /repos/$OWNER/$REPO/actions/runs/{}


# delete newest 10 workflows (won't delete the running one)
gh api -X GET /repos/$OWNER/$REPO/actions/workflows/$WORKFLOW_ID/runs | jq '.workflow_runs[] | .id' | head -n 10 | xargs -I{} gh api -X DELETE /repos/$OWNER/$REPO/actions/runs/{}
