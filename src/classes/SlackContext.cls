/**
* @author Christian Carter (@cdcarter)
* @date Jan 2016
*
*
* @description A set of helper types and methods for handling Slack requests 
* and creating Slack responses.
*/
global class SlackContext {
    public SlackRequest request {get;set;}
    public SlackResponse response {get;set;}
    public RestRequest rest_request {get;set;}
    
    public class BadTokenException extends Exception {}
    
    global SlackContext(RestRequest req) {
        this.request = new SlackRequest(req.params);
        this.response = new SlackResponse();
        this.rest_request = req;
    }
    
    global void checkToken(String real_token){
        if(real_token != request.token){
            throw new BadTokenException('Request token was not correct');
        }
    }
    
    global void setResponse(RestResponse resp) {
        JSONGenerator gen = JSON.createGenerator(true);
        this.response.serialize(gen);
        //System.debug(gen.getAsString());
        resp.addHeader('Content-Type', 'application/json');
        resp.responseBody = Blob.valueOf(gen.getAsString());
    }
    
    public class SlackRequest {
        public String token {get; private set;}
        public String team_id {get; private set;}
        public String team_domain {get; private set;}
        public String channel_id {get; private set;}
        public String channel_name {get; private set;}
        public String user_id {get; private set;}
        public String user_name {get; private set;}
        public String command {get; private set;}
        public String text {get; private set;}
        public String response_url {get; private set;}
        
        // construct a SlackRequest from a RestRequest.params Map
        public SlackRequest(Map<String,String> params) {
            this.token = params.get('token');
            this.team_id = params.get('team_id');
            this.team_domain = params.get('team_domain');
            this.channel_id = params.get('channel_id');
            this.channel_name = params.get('channel_name');
            this.user_id = params.get('user_id');
            this.user_name = params.get('user_name');
            this.command = params.get('command');
            this.text = params.get('text');
            this.response_url = params.get('response_url');
        }
    }
    
    global class SlackResponse {
        public String text {get ;set;}
        public Boolean mrkdwn {get;set;}
        public String response_type {get;set;}
        public string username {get;set;}
        public string icon_emoji {get;set;}
        public List<SlackAttachment> attachments {get;set;}
        
        public SlackResponse() {
            this.attachments = new List<SlackAttachment>();
        }
        
        public JSONGenerator serialize(JSONGenerator gen) {
            gen.writeStartObject();
            if(this.text != null)
            gen.writeStringField('text', escapeString(text));
            if(this.mrkdwn != null) gen.writeBooleanField('mrkdwn', mrkdwn);
            if(this.username != null) gen.writeStringField('username', username);
            if(this.icon_emoji != null) gen.writeStringField('icon_emoji', icon_emoji);
            if(this.response_type != null)
            gen.writeStringField('response_type', response_type);
            if(this.attachments != null && this.attachments.size() > 0) {
                gen.writeFieldName('attachments');
                gen.writeStartArray();
                for(SlackAttachment attachment : this.attachments) {
                    attachment.serialize(gen);
                }
                gen.writeEndArray();
            }
            gen.writeEndObject();
            return gen;
        }
    }
    
    global class SlackAttachment {
        public String text {get ;set;}
        public String pretext {get ;set;}
        public String title {get ;set;}
        public String fallback {get ;set;}
        public String color {get ;set;}
        public String title_link {get ;set;}
        public String image_url {get ;set;}
        public String thumb_url {get ;set;}
        public String author_name {get ;set;}
        public String author_link {get ;set;}
        public String author_icon  {get ;set;}
        public List<SlackField> fields {get;set;}
        
        public SlackAttachment() {
            this.fields = new list<SlackField>();
        }
        
        public List<String> mrkdwn_in {get;set;}
        
        public JSONGenerator serialize(JSONGenerator gen) {
            gen.writeStartObject();
            if(text != null) gen.writeStringField('text',escapeString(text));
            if(pretext != null) gen.writeStringField('pretext', escapeString(pretext));
            if(fallback != null) gen.writeStringField('fallback', escapeString(fallback));
            if(color != null) gen.writeStringField('color', escapeString(color));
            if(title != null) gen.writeStringField('title', escapeString(title));
            if(title_link != null) gen.writeStringField('title_link', escapeString(title_link));
            if(image_url != null) gen.writeStringField('image_url', escapeString(image_url));
            if(thumb_url != null) gen.writeStringField('thumb_url', escapeString(thumb_url));
            if(author_name != null) gen.writeStringField('author_name', escapeString(author_name));
            if(author_link != null) gen.writeStringField('author_link', escapeString(author_link));
            if(author_icon != null) gen.writeStringField('author_icon', escapeString(author_icon));
            if(fields != null && fields.size() != 0) {
                gen.writeFieldName('fields');
                gen.writeStartArray();
                for(SlackField field : fields ) {
                    field.serialize(gen);
                }
                gen.writeEndArray();
            }
            gen.writeEndObject();
            return gen;
        }
    }
    
    global class SlackField {
        public String title {get ;set;}
        public String value {get ;set;}
        
        public SlackField(String t, String v) {
            this.title = t;
            this.value = v;
        }
        
        public JSONGenerator serialize(JSONGenerator gen) {
            if(title != null && value != null){
                gen.writeStartObject();
                gen.writeStringField('title', escapeString(title));
                gen.writeStringField('value', escapeString(value));
                gen.writeEndObject();
            }
            return gen;
        }
    }
    
    global static String escapeString(String str) {
        return str.replace('&','&amp;').replace('<','&lt;').replace('>','&gt;');
    }
}
/*
Copyright (c) 2015 Christian Carter
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of Christian Carter nor the names of
its contributors may be used to endorse or promote products derived
from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
*/