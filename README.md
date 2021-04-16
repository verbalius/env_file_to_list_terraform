# env_file_to_list_terraform

Terraform module that transforms regular env file to terraform list with objects:

```
{
    name  = "name",
    value = "value"
}
```

## Inputs

| name          | type   | required |
| ---           | ---    | ---      |
| env_file_path | string | yes      |

## Env file structure

! Please don't use spaces without brackets " "

It is better to use this format var="value"

### Input

file.env:

```
VARIABLE1=vlaue1
# some comment w/ random &$02 content that
# are being ignored
API_URL=https://example.com
PASSWORD="983b6987rc1tx38e735v^&$F^%TUR56"
foo="foo bar foobar"
```

### Result

env_list:

```
[
    {
        name = "VARIABLE1"
        vlaue = "vlaue1"
    },
    {
        name = "API_URL"
        vlaue = "https://example.com"
    },
    {
        name = "PASSWORD"
        vlaue = "983b6987rc1tx38e735v^&$F^%TUR56"
    },
    {
        name = "foo"
        vlaue = "foo bar foobar"
    }
]
```

# Examples

Please see example folder to see how to use the module