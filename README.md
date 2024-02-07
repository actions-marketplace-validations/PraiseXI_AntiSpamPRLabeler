# AntiSpamPRLabeler

This GitHub Action automatically labels and comments on pull requests based on the number of changes. It's designed to help maintainers quickly identify potential spam or small contributions by automatically labeling pull requests as 'Potential Spam' if they contain a small number of changes and commenting for further review.

## Prerequisites

This action requires the `GITHUB_TOKEN` with permissions to fetch PRs and add labels and comments. The action uses this token to authenticate API requests, ensuring secure and permissioned interactions with your repository.

## Usage

To incorporate this action into your workflow, add the following step to your GitHub Actions workflow file (e.g., `.github/workflows/antispam-pr-labeler.yml`):

```yaml
- name: Label and Comment PRs
  uses: PraiseXI/AntiSpamPRLabeler@v1
  with:
    repo-token: ${{ secrets.GITHUB_TOKEN }}

```
This snippet shows how to configure the action to use the built-in `GITHUB_TOKEN` for API requests.
## Inputs

`repo-token`: **Required**. The GitHub token used to authenticate API requests. This should generally be set to **`${{ secrets.GITHUB_TOKEN }}`** to utilize the automatic token GitHub provides.

## Outputs
There are no outputs defined for this action. Its primary function is to label and comment on PRs directly.


## Example Workflow
Below is a full example demonstrating how to set up a workflow that uses the AntiSpamPRLabeler action. This workflow triggers on pull request events to label and comment as needed.

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
      uses: PraiseXI/AntiSpamPRLabeler@v1
      with:
        repo-token: ${{ secrets.GITHUB_TOKEN }}
```
## Contributing
Contributions to the PR Labeler and Commenter Action are welcome! Please submit pull requests or open issues with your suggestions.

## License
Distributed under the MIT License. See LICENSE for more information.