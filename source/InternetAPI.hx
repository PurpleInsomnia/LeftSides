package;

import haxe.Http;
import haxe.io.Bytes;

using StringTools;

class InternetAPI
{
    public static function getArrayFromFile(link:String)
    {
        var http = new Http(link);

        http.onData = function(data:String)
        {
            var ret:Array<String> = data.trim().split("\n");
            return ret;
        }

        http.onError = function(error)
        {
            trace('error: $error');
            return [];
        }

        http.request();
    }

    public static function getTextFromFile(link:String)
    {
        var http = new Http(link);

        http.onData = function(data:String)
        {
            return data;
        }

        http.onError = function(error)
        {
            trace('error: $error');
            return "";
        }

        http.request();
    }

    public static function getBytesFromFile(link:String)
    {
        var http = new Http(link);

        http.onBytes = function(bytes:Bytes)
        {
            return bytes;
        }

        http.onError = function(error)
        {
            trace('error: $error');

            return null;
        }

        http.request();
    }
}