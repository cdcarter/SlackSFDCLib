/**
* @author Christian Carter (@cdcarter)
* @date Jan 2016
*
*
* @description Tests the basic functionality and serialization of SlackContext objects
*/

@isTest
public class SlackContext_Test {
    @isTest public static void test_escapeString() {
        String input = 'Hello < there & friend >';
        String expected = 'Hello &lt; there &amp; friend &gt;';
        System.assertEquals(expected, SlackContext.escapeString(input), '<,>,& should be escaped');
    }
    
    @isTest public static void test_checkToken() {
        string TOKEN = 'abc123';
        RestRequest req = new RestRequest();
        req.addParameter('token', 'abc123');
        SlackContext ctx = new SlackContext(req);
        ctx.checkToken(TOKEN); // should not error.
        TOKEN = 'lolol';
        String eType = '';        
        try {
            ctx.checkToken(TOKEN);
        } catch(Exception e) {
            eType = e.getTypeName();
        }
        String typeName = SlackContext.BadTokenException.class.getname();
        System.assertEquals(typeName, eType, 'An invalid token should throw a BadTokenException');
    }
    
    @isTest public static void test_setResponse() {
        RestRequest req = new RestRequest();
        req.addParameter('token', 'abc123');
        SlackContext ctx = new SlackContext(req);
        RestResponse resp = new RestResponse();
        ctx.setResponse(resp);
        System.assertEquals('application/json', resp.headers.get('Content-Type'));
    }
    
    @isTest public static void test_serializeSimpleResponse() {
        SlackContext.SlackResponse resp = new SlackContext.SlackResponse();
        resp.text = 'Hello there!';
        resp.response_type = 'ephemeral';
        System.assertEquals(resp.attachments.size(), 0, 'Attachments should be initialized but empty');
        JSONGenerator gen = JSON.createGenerator(true);
        resp.serialize(gen);
        String result = gen.getAsString();
        System.assert(result.contains('ephemeral'));
        Map<String,Object> deserialized = (Map<String,Object>)JSON.deserializeUntyped(result);
        system.assertEquals('Hello there!', (String)deserialized.get('text'));
    }
    
    @isTest public static void test_serializeSlackFields() {
        SlackContext.SlackField field = new SlackContext.SlackField('project','Super Project');
        JSONGenerator gen = JSON.createGenerator(true);
        field.serialize(gen);
        String result = gen.getAsString();
        System.assert(result.contains('Super Project'));
        Map<String,Object> deserialized = (Map<String,Object>)JSON.deserializeUntyped(result);
        system.assertEquals('project', (String)deserialized.get('title'));
    }
    
    @isTest public static void test_serializeSlackAttachment() {
        SlackContext.SlackAttachment a = new SlackContext.SlackAttachment();
        a.title = 'Super Attachment';
        a.text = 'Inline!';
        a.color = 'red';
        JSONGenerator gen = JSON.createGenerator(true);
        a.serialize(gen);
        String result = gen.getAsString();
        System.assert(result.contains('red'));
        Map<String,Object> deserialized = (Map<String,Object>)JSON.deserializeUntyped(result);
        System.assertEquals('Inline!', (String)deserialized.get('text'));
    }
    
    @isTest public static void test_serializeComplexResponse() {
        SlackContext.SlackResponse resp = new SlackContext.SlackResponse();
        resp.text = 'Hello there!';
        resp.response_type = 'ephemeral';
        SlackContext.SlackAttachment a = new SlackContext.SlackAttachment();
        a.title = 'Super Attachment';
        a.text = 'Inline!';
        a.color = 'red';
        SlackContext.SlackField field = new SlackContext.SlackField('project','Super Project');
        a.fields.add(field);
        resp.attachments.add(a);
        JSONGenerator gen = JSON.createGenerator(true);
        resp.serialize(gen);
        String result = gen.getAsString();
        System.assert(result.contains('red'));
        Map<String,Object> deserialized = (Map<String,Object>)JSON.deserializeUntyped(result);
        List<Object> attachments = (List<Object>)deserialized.get('attachments');
        System.assertEquals(1, attachments.size());
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