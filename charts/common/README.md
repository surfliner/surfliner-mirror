# Common

Common is a Helm [library chart][library chart link] that aggregates analogous template functions across surfliner charts into single definitions to be re-used across different charts, avoiding duplicate definitions and repetition. 

## Using the Chart

To use the chart for a surfliner chart:

1. Include Common as a dependency in the chart's `Chart.yaml` file by appending the following under the `dependencies` block.
```
  - name: common
    version: 0.1.0
    repository: file://../common
```
2. Replace your chart's functions with analogous Common chart definitions using `include` statements. 

For example: 
The template function `shoreline.name` in the Shoreline chart's `_helpers.tpl` file is originally as follows:
```
{{- define "shoreline.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
```

It is analogous to the Common chart's `common.name` template function:

```
{{- define "common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
```

So, `shoreline.name`'s definition can be replaced with an `include` statement referencing the `common.name` template function:

``` 
{{- define "shoreline.name" -}}
{{ include "common.name" . }}
{{- end -}}
```

3. For usage by a chart with a name `chartname`:
```console
$ helm dep update charts/chartname
```

[library chart link]:https://helm.sh/docs/topics/library_charts/
