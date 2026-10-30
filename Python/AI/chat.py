import os
from azure.identity import DefaultAzureCredential
from azure.ai.projects import AIProjectClient

def main():
    print("Starting chat...")
    project_endpoint = os.environ["FOUNDRY_PROJECT_ENDPOINT"]
    with (DefaultAzureCredential() as credential, AIProjectClient(endpoint=project_endpoint,credential=credential) as project_client):
        client = project_client.get_openai_client(agent_name="monday-agent")
        conversation = client.conversations.create()
        while True:
            user_input = input("> ")
            if user_input.lower() == "exit":
                break
            current_input = user_input
            response = client.responses.create(
                input=current_input,
                conversation=conversation.id
            )
            print(response.output_text)

if __name__ == "__main__":
    main()