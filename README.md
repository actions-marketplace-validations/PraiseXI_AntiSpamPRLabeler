# AntiSpamPRLabeler

This GitHub Action automatically labels and comments on pull requests based on the number of changes. It's designed to help maintainers quickly identify potential spam or small contributions.

## Prerequisites

This action requires the `GITHUB_TOKEN` with permissions to fetch PRs and add labels and comments.

## Usage

To use this action, add the following step to your GitHub Actions workflow:

```yaml
- name: Label and Comment PRs
  uses: PraiseXI/pr-labeler-commenter-action@v1
  with:
    repo-token: ${{ secrets.GITHUB_TOKEN }}
```

## Inputs

repo-token: Required. The GitHub token used to authenticate API requests.

## Outputs
No outputs are defined for this action.

## Example Workflow
```yaml
name: Automate PR Labeling and Commenting

on: [pull_request]

jobs:
  label-and-comment:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v2
    - name: Label and Comment PRs
      uses: PraiseXI/pr-labeler-commenter-action@v1
      with:
        repo-token: ${{ secrets.GITHUB_TOKEN }}
```
## Contributing
Contributions to the PR Labeler and Commenter Action are welcome! Please submit pull requests or open issues with your suggestions.

## License
Distributed under the MIT License. See LICENSE for more information.