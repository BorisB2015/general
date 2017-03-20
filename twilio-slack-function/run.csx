#r "Newtonsoft.Json"
#r "System.Web"

using System;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Net.Http.Headers;
using System.Web;
using System.Text;
using Newtonsoft.Json;
using System.Collections.Specialized;
using System.Xml;

public static async Task<object> Run(HttpRequestMessage req, TraceWriter log)
{
    log.Info($"Twilio was triggered!");

    // parse parameters
        
    //log.Info(req.Headers.Accept.ToString());

    // Get request body
    dynamic data = await req.Content.ReadAsStringAsync();
    log.Info(data.ToString());
    NameValueCollection qscoll = HttpUtility.ParseQueryString(data.ToString());

    foreach (String s in qscoll.AllKeys)
    {
      log.Info(s + " - " + qscoll[s]);
    }

    string smsBody = qscoll["Body"];
    string smsFrom = qscoll["From"];
    string smsTo = qscoll["To"];
    string smsNumSegments = qscoll["NumSegments"];
    string smsNumMedia = qscoll["NumMedia"];
    string smsAccountSid = qscoll["AccountSid"];
    string smsMessageSid = qscoll["MessageSid"];
    
    using (var client = new HttpClient())
    {
        var textContent = "(From: " + smsFrom + ", Segs: " + smsNumSegments + ", Media: " + smsNumMedia + ", To: " + smsTo + ")>" + smsBody;
        var numMedia = Convert.ToInt32(smsNumMedia);
        if (numMedia > 0) {
            // Get media list
            // Define TwilioAuthKey app parameter and set it to Auth key found in Twilio for your number
            var authHeader = new AuthenticationHeaderValue("Basic", Convert.ToBase64String(ASCIIEncoding.ASCII.GetBytes(Environment.GetEnvironmentVariable("TwilioAuthKey"))));
            client.DefaultRequestHeaders.Authorization = authHeader;

            var url1 = "https://api.twilio.com/2010-04-01/Accounts/" 
                    + smsAccountSid + "/Messages/" + smsMessageSid + "/Media";
            //log.Info(url1);
            var response1 = await client.GetAsync(url1);
            //log.Info("response1");
            var responseString1 = await response1.Content.ReadAsStringAsync();
            //log.Info(responseString1);
            
            var xmlDocument = new XmlDocument();
            xmlDocument.LoadXml(responseString1);
            
            XmlNodeList uriList = xmlDocument.SelectNodes("//Uri");
            for (int i = 0; i < uriList.Count; i++) {
                //textContent += "\n" + "<https://api.twilio.com/" + uriList.Item(i).InnerXml 
                //    + "|Media" + i + ">";
                textContent += "\n" + "https://api.twilio.com/" + uriList.Item(i).InnerXml;    
            }
            
        }

        //log.Info(textContent);
        
        var values = new Dictionary<string, object>
        {
            { "text", textContent },
            { "mrkdwn", false }
        };
        
        var response = await client.PostAsJsonAsync(
            // define SlackHookURL in App parameters and set to desired channel in Slack
            Environment.GetEnvironmentVariable("SlackHookURL"),
            values);
        var responseString = await response.Content.ReadAsStringAsync();
        log.Info("Slack: " + responseString);
    }
    return req.CreateResponse(HttpStatusCode.NoContent, "", new XmlMediaTypeFormatter());
}