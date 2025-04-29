#!/bin/bash
echo "Resetting the demo data..."
# setting the context
name_space="axl2"
api_url="https://photo-demo.westeurope.cloudapp.azure.com/axl2/api"
# api_url="https://api.k8s.orb.local/axl/api"

# Run kubectl get pods command and store the output in a variable
kubectl_output=$(kubectl get pods -n $name_space)

# Check if the kubectl command was successful
if [ $? -eq 0 ]; then
    # Extract the pod names containing "pixidb" from the output using grep
    pod_names=$(echo "$kubectl_output" | grep "pixidb" | awk '{print $1}')

    # Check if any pod names were extracted
    if [ -n "$pod_names" ]; then
        echo "The pods containing 'pixidb' in their names are:"
        echo "$pod_names"

        # Delete each of the pods containing "pixidb"
        for pod_name in $pod_names; do
            kubectl delete pod "$pod_name" -n $name_space
            if [ $? -eq 0 ]; then
                echo "Deleted pod: $pod_name"
            else
                echo "Error: Failed to delete pod: $pod_name"
            fi
        done

        # Wait for a few seconds to allow the new pod to be created
        sleep 10

        # Get the name of the newly created pod containing "pixidb"
        new_pod_name=$(kubectl get pods -n $name_space | grep "pixidb" | awk '{print $1}' | head -n 1)

        if [ -n "$new_pod_name" ]; then
            echo "New pod name: $new_pod_name"

            api_url="https://photo-demo.westeurope.cloudapp.azure.com/axl2/api"
            # api_url="https://api.k8s.orb.local/axl/api"

            # JSON data for the API request 
            json_data_user_inbound='{"user": "scanuser@test.com","pass": "hellopixi","name": "Scan Test User","is_admin": true,"account_balance": 1000}'
            json_data_user_common='{"user": "attacks-demo@acme.com","pass": "hellopixi","name": "Attack User","is_admin": false,"account_balance": 1000}'
            json_data_user_admin='{"user": "useradmin@acme.com","pass": "hellopixi","name": "Scan Admin User","is_admin": true,"account_balance": 1000}'
            json_data_user_scan='{"user": "userscan-run@acme.com","pass": "hellopixi","name": "Scan Run User","is_admin": false,"account_balance": 1000}'
            json_data_user_pixiadmin='{"user": "pixiadmin@demo.mail","pass": "adminpixi"}'

            # Invoke the API using curl with POST method and passing the JSON data
            echo "Creating test and attack users..."
            curl_response_inbound=$(curl -s -k -X POST -H "Content-Type: application/json" -d "$json_data_user_inbound" "$api_url/user/register")
            curl_response_common=$(curl -s -k -X POST -H "Content-Type: application/json" -d "$json_data_user_common" "$api_url/user/register")
            curl_response_pixiadmin=$(curl -s -k -X POST -H "Content-Type: application/json" -d "$json_data_user_pixiadmin" "$api_url/user/login")
            



            if [ $# -eq 1 ]; then
                echo "Creating admin and scan users..."
                curl_response_admin=$(curl -s -k -X POST -H "Content-Type: application/json" -d "$json_data_user_admin" "$api_url/user/register")
                curl_response_scan=$(curl -s -k -X POST -H "Content-Type: application/json" -d "$json_data_user_scan" "$api_url/user/register")
            fi

            #JSON data for uploading pictures
            curl_response_barbara=$(curl -s -k -X POST -H "Content-Type: application/json" -d '{"user": "barbara8@demo.mail","pass": "ball"}' "$api_url/user/login")
            curl_response_misty=$(curl -s -k -X POST -H "Content-Type: application/json" -d '{"user": "misty94@demo.mail","pass": "ball"}' "$api_url/user/login")

            # Check the curl response
            if [ $? -eq 0 ]; then
                echo "Test User: $curl_response_inbound"
                echo "Attack User: $curl_response_common"
                echo "Pixi Admin User: $curl_response_pixiadmin"

                if [ $# -eq 1 ]; then
                    echo "Admin User: $curl_response_admin"
                    echo "Scan User: $curl_response_scan"
                fi

                # Extract the token from the JSON response using jq
                token=$(echo "$curl_response_pixiadmin" | jq -r '.token')

                if [ -n "$token" ]; then
                    adminId=$(echo $curl_response_pixiadmin | jq -r '._id')
                    echo -e "Admin ID : $adminId"
                    # export PIXI_TOKEN="$token"

                    echo "Admin deleting Barbara picture..."
                    curl -k -X DELETE -H "x-access-token: $token" "$api_url/picture/f83b97ae-1783-47fa-99ab-5ce5f6523e9e"
                else
                    echo "Error: Failed to extract token from Admin API response."
                fi

                # Extract the token from the JSON response using jq
                token=$(echo "$curl_response_misty" | jq -r '.token')

                if [ -n "$token" ]; then
                    mistyId=$(echo $curl_response_misty | jq -r '._id')
                    echo -e "\nMisty User ID : $mistyId"
                    # export PIXI_TOKEN="$token"

                    echo "Creating all pictures for Misty..."
                    curl -s -k -X POST -H "Content-Type: application/json" -H "x-access-token: $token" -d '{"filename": "https://i.imgur.com/vTsVEQF.jpeg","title": "Sesame dog"}' "$api_url/picture/file_upload"
                    curl -s -k -X POST -H "Content-Type: application/json" -H "x-access-token: $token" -d '{"filename": "https://i.imgur.com/QLQyd0e.jpeg","title": "Sesame pup"}' "$api_url/picture/file_upload"
                    curl -s -k -X POST -H "Content-Type: application/json" -H "x-access-token: $token" -d '{"filename": "https://i.imgur.com/aDxEYow.jpeg","title": "Doggy toy"}' "$api_url/picture/file_upload"
                    curl -s -k -X POST -H "Content-Type: application/json" -H "x-access-token: $token" -d '{"filename": "https://i.imgur.com/1D2jSkt.jpeg","title": "Sesame doggy"}' "$api_url/picture/file_upload"
                    curl -s -k -X POST -H "Content-Type: application/json" -H "x-access-token: $token" -d '{"filename": "https://i.imgur.com/bAKUBwj.jpeg","title": "Sesame puppy"}' "$api_url/picture/file_upload"
                else
                    echo "Error: Failed to extract token from Misty API response."
                fi

                # Extract the token from the JSON response using jq
                token=$(echo "$curl_response_barbara" | jq -r '.token')

                if [ -n "$token" ]; then
                    barbaraId=$(echo $curl_response_barbara | jq -r '._id')
                    echo -e "\nBarbara User ID : $barbaraId"
                    # export PIXI_TOKEN="$token"

                    #Upload photos to user
                    echo "Creating all pictures for Barbara..."
                    curl -s -k -X POST -H "Content-Type: application/json" -H "x-access-token: $token" -d '{"filename": "https://i.imgur.com/WgIfSYW.jpeg","title": "My silly pugs"}' "$api_url/picture/file_upload"
                    curl -s -k -X POST -H "Content-Type: application/json" -H "x-access-token: $token" -d '{"filename": "https://i.imgur.com/LnAowS0.jpeg","title": "Smile puppy"}' "$api_url/picture/file_upload"
                else
                    echo "Error: Failed to extract token from Barbara API response."
                fi


                # Forward the pod port to localhost:27017
                # kubectl port-forward "$new_pod_name" 27017:27017 -n axl

                now="$(date +"%Y-%m-%d-%T")"
                echo -e "\nTime : $now"

            else
                echo "Error: Failed to invoke the API."
            fi
        else
            echo "No new pod found containing 'pixidb' in its name."
        fi
    else
        echo "No pods found containing 'pixidb' in their names."
    fi
else
    echo "Error: Unable to run kubectl command. Please make sure kubectl is installed and configured correctly."
fi
