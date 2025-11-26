
# **Manual Installation Guide: DevOps Toolchain for Windows**

This document outlines the manual installation steps for **Git**, **Terraform**, **Terragrunt**, and **Google Cloud SDK (gcloud CLI)** on Windows. This method does not require package managers (like Chocolatey) and allows for precise control over versioning and binary locations.

## **📋 Prerequisites**

* Windows 10 or Windows 11  
* Administrator privileges

---

## **1\. Install Git**

1. Navigate to the [official Git website](https://git-scm.com/download/win).  
2. Download the **64-bit Git for Windows Setup**.  
3. Run the installer.  
4. **Note:** You can generally accept all default settings by clicking "Next" through the wizard.

---

## **2\. Setup Binary Directory (Terraform & Terragrunt)**

Since Terraform and Terragrunt are distributed as single binaries, we will create a dedicated location for them.

1. Open File Explorer.  
2. Create a folder on your C: drive (or preferred drive) named DevOps.  
   * **Path:** C:\\DevOps

### **Install Terraform**

1. Go to the [Terraform Downloads page](https://developer.hashicorp.com/terraform/install).  
2. Select **Windows** and download the **AMD64** ZIP file.  
3. Extract the terraform.exe file from the ZIP.  
4. Move terraform.exe into C:\\DevOps.

### **Install Terragrunt**

1. Go to the [Terragrunt Releases page](https://github.com/gruntwork-io/terragrunt/releases).  
2. Click the latest release version.  
3. Scroll down to **Assets** and download terragrunt\_windows\_amd64.exe.  
4. Move the file to C:\\DevOps.  
5. **Critical Step:** Rename the file from terragrunt\_windows\_amd64.exe to terragrunt.exe.

---

## **3\. Configure System Environment Variables**

For Windows to recognize terraform and terragrunt commands from any terminal window, you must add your binary folder to the System Path.

1. Press the **Windows Key** and type env.  
2. Select **Edit the system environment variables**.  
3. Click the **Environment Variables...** button near the bottom.  
4. In the **System variables** section (bottom pane), scroll down and select **Path**, then click **Edit**.  
5. Click **New**.  
6. Type the path to your folder: C:\\DevOps.  
7. Click **OK** on all three open windows to save and close.

---

## **4\. Install Google Cloud SDK**

1. Download the [Google Cloud SDK Installer](https://www.google.com/search?q=https://cloud.google.com/sdk/docs/install%23windows).  
2. Run the executable.  
3. **Note:** Ensure the checkbox to install **bundled Python** is selected (unless you have a specific reason to manage Python manually).  
4. Complete the installation wizard.

---

## **5\. Verification**

**Important:** You must close any open terminal windows and open a **new** PowerShell or Command Prompt for the Path changes to take effect.

Run the following commands to verify installation:

PowerShell

\# Check Git  
git \-\-version

\# Check Terraform  
terraform \-v

\# Check Terragrunt  
terragrunt \-v

\# Check Google Cloud SDK  
gcloud \-v

---

## **6\. Initialization**

Once verified, initialize the Google Cloud CLI:

Bash

gcloud init

This will launch your browser to authenticate with your Google account and ask you to select your GCP Project.

