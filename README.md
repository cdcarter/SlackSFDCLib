# SlackSFDClib

SlackSFDClib is a set of helper types and functions to build quick Slack Integrations in Salesforce. Quickly create a SlackContext from a RestContext and roll from there.

## Getting Started

1. Install SlackSFDClib in your organization as an unmanaged package from https://login.salesforce.com/packaging/installPackage.apexp?p0=04t36000000DZnG
2. Create a new class using the sample structure below.
3. Add functionality to your Slackbot class.
4. Create a force.com public site (or using an existing one) and then add your Slackbot class to the site guest user's enabled Apex Classes.
5. Create a new slash command integration in your Slack team. Point it to https://yourdomain.force.com/yoursite/services/apexrest/slackbot/.
6. Grab the token from the slack integration configuration page, and paste it into your Slackbot class.
7. Enjoy!

## Basic Slackbot

```
@restResource(urlMapping='/slackbot/*')
global class SlackBot {
	static final string SLACK_TOKEN='PASTE_TOKEN_HERE';

	@httpPost
	global static void doPost() {
		SlackContext ctx = new SlackContext(RestContext.request);				
		ctx.checkToken(SLACK_TOKEN);
		ctx.response.response_type='ephemeral';

		// DO WORK HERE
		ctx.response.text = 'Thanks for calling Salesforce!';

		ctx.setResponse(RestContext.response);
	}
}
```

To make this class testable, you may want to pull your logic into a method that returns a SlackContext object.
