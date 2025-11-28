# GCP Slack Notification Channel with Terraform

This guide provides a step-by-step walkthrough on how to provision a Google Cloud Platform (GCP) Monitoring notification channel for Slack using Terraform. This allows you to send alerts from GCP services directly to a designated Slack channel.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Step 1: Configure Your Slack App](#step-1-configure-your-slack-app)
- [Step 2: Write the Terraform Configuration](#step-2-write-the-terraform-configuration)


---

## Prerequisites

Before you start, ensure you have the following:

- A Google Cloud Platform (GCP) project with the **Cloud Monitoring API** enabled.
- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- The `gcloud` CLI installed and authenticated to your GCP account (`gcloud auth application-default login`).
- Administrative permissions in a Slack workspace to create and manage apps.

---

## Step 1: Configure Your Slack App

You need to create a Slack App to handle incoming webhooks from GCP.

1.  **Create a New Slack App**:
    - Go to the [Slack API website](https://api.slack.com/apps).
    - Click **"Create New App"** and select **"From scratch"**.
    - Give your app a name (e.g., "GCP Alerter") and select your target Slack workspace.

2.  **Set OAuth Permissions (Scopes)**:
    - In your app's settings, navigate to the **"OAuth & Permissions"** page from the sidebar.
    - Scroll down to the "Scopes" section. Under **"Bot Token Scopes"**, click **"Add an OAuth Scope"** and add the following:
      - `chat:write`
      - `chat:write.public`
      - `incoming-webhook`

3.  **Install the App to Your Workspace**:
    - Scroll back to the top of the "OAuth & Permissions" page.
    - Click **"Install to Workspace"** and follow the prompts to authorize the app.

4.  **Get Credentials**:
    - **Bot Token**: After installation, the page will display a **"Bot User OAuth Token"**. It starts with `xoxb-`. Copy this token. This will be your `slack_token` in Terraform.
    - **Channel ID**:
      - Go to the Slack channel you want to use for notifications.
      - Invite the app to the channel by typing `@YourAppName` and sending the message.
      - To get the Channel ID, right-click on the channel name in Slack, select **"Copy link"**, and paste it somewhere. The ID is the last part of the URL (e.g., for `https://your-workspace.slack.com/archives/C0123ABCDE`, the ID is `C0123ABCDE`).

**Treat the Bot Token as a highly sensitive secret.**

---

## Step 2: Write the Terraform Configuration

Next, you will define the GCP notification channel as a resource in Terraform.
