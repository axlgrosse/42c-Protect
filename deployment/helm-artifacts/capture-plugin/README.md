#How to install

1. Create a API token from the platform (no special rights are required)
2. Create a bucket and copy its ID (copy button top right)
3. Edit values.yaml and set bucket ID
4. Adjust targetServer depending on the one you use.

```
config:
  bucketId: "3b1a1577-6d37-4ce2-97d3-f1fbf4cfec3e"
  # Make sure the URL ends with a / or the container will fail to start.
  targetServer: "https://demolabs.42crunch.cloud/capture/"
``` 
5. Install the helm chart
 `helm install capture-agent ./capture-plugin --debug --set-string config.accessToken=api_755eeea3-0d45-49ba-8fbb-cxxxxx`
