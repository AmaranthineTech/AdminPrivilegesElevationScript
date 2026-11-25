# AdminPrivilegesElevationScript

## Script Details
### Name 	
adminPrivsElevationScript.zsh

### Author
Arun Patwardhan
arun@amaranthine.co.in

## Legal Disclaimer 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Description
- This script is intended for elevating the privieges for a user to **admin** for a limited period. 
- Any user should be able to run this script.
- This script can run on all computers.
- The time options available are included in the preference file. It is expected that this is configured by the MDM. 
- In case the MDM has not configured the file, then the script will automatically generate one with predefined values of
   + 5 minutes
   + 10 minutes
   + 15 minutes
   + 20 minutes

## Usage 
- Run the command:
  ```shell
  ./adminPrivsElevationScript.zsh
  ```
_* This script is intended for use via an MDM. *_

## Warning/Caution
- This script doesn't perform any validation. 
- The script must be run with sudo privileges.
- Please test the script before deploying

## Installation 
### Instructions for placing the script in the correct place are listed here. 
Location:		`/Library/Scripts/`

Permissions:	`rwx r-x r-x`

## Requirements 
Shell:		    `/bin/zsh`

OS:			      macOS Golden Gate 27.0.1 or later

Dependencies:	None

## Troubleshooting 
You can also view the log file for the same at: /Library/Logs/adminPrivelegesElevationScript_events.log

## History 
Version 1.0: Basic script which elevates privileges
