# Helm Tips and Tricks

## Completion

Most package managers _should_ install the [Helm completions][helm-completion] automatically when installed the `helm`
package. However, if for some reason your package manager doesn't, the documentation provides instructions for installing the completion
file(s) for your shell of choice.

This let's you use tab-completion when typing out `helm` commands in the shell, which can save a lot of time and errors.

## Always update the chart dependencies

If you are working on an existing chart, prior to starting development it is always a good idea to ensure you're working
with the latest versions of the chart dependencies locally. Not taking this step can cause you to not notice changes,
and potentially bugs, until a `review` application is built in CI.

For this we use the [`helm dependency update`][helm-dep-up] command.

Taking the `shoreline` chart for example:

```sh
$ cd surfliner/charts/shoreline
$ helm dependency update . # or shorthand -- helm dep up .
```

## Modifying an existing deployment

When modifying a chart configuration, it can be helpful to do some testing using real values from existing deployments,
such as `staging` or `production`.

Helm provides a helpful command, [`helm get values`][helm-get-values] to quickly gather all the values of an _existing_ deployment so that those values
may be used locally for testing and development.

Using this in a surfliner workflow might look like the following:

First save the values of the current `shoreline` `staging` deployment to a file `/tmp/shoreline-staging.yaml`

```sh
$ helm get values --namespace shoreline-staging surfliner-shoreline-stage > /tmp/shoreline-staging.yaml
```

Now that you have values stored. Here are some ways you can use it.

### One-off deploy of a branch

Sometimes it's helpful to try out a new version of the application deployed in an environment, like `staging`, with real
production data.

General steps:
- Locate and copy the image tag from the `build` job in the branch pipeline
- Replace the `image.tag` value in the file downloaded via `helm get values`, in our case `/tmp/shoreline-staging.yaml`
- Run a helm deployment referencing your modified `/tmp/shoreline-staging.yaml` values file

```sh
# edit image.tag in your editor
$ cd surfliner/charts/shoreline
$ helm upgrade --install --debug --atomic --values /tmp/shoreline-staging.yaml --namespace shoreline-staging surfliner-shoreline-stage ./
```

### Check values against local chart changes

If you are editing a Helm chart locally, say adding a new template or modifying a template, it can be very helpful to
validate what the generated template(s) and values will look like when your changes are applied. For this you can
leverage the `--dry-run` flag. This will render the templates and values using your local chart changes and you can use
the `--values` flag to reference your saved `/tmp/shoreline-staging.yaml` values.

```sh
$ cd surfliner/charts/shoreline
$ helm upgrade --install --dry-run --debug --values /tmp/shoreline-staging.yaml --namespace shoreline-staging surfliner-shoreline-stage ./
```

See [`helm.sh Debugging Templates`][helm-debugging] for more debugging ideas.

## Resources

[helm.sh Tips and Tricks](https://helm.sh/docs/howto/charts_tips_and_tricks/)

[helm-completion]:https://helm.sh/docs/helm/helm_completion/#helm
[helm-debugging]:https://helm.sh/docs/chart_template_guide/debugging/#helm
[helm-dep-up]:https://helm.sh/docs/helm/helm_dependency_update/#helm
[helm-get-values]:https://helm.sh/docs/helm/helm_get_values/#helm
