module moddl.api;

import moddl.utils;

long cmpVersion(string a, string b){
	import std.string;
	import std.algorithm;
	import std.range;
	import std.conv : to;

	auto x = a.split(".").map!(a => a.to!int);
	auto y = b.split(".").map!(a => a.to!int);

	auto z = zip(x, y);
	foreach(k; z){
		if(k[0] < k[1]){
			return -1;
		}else if(k[0] > k[1]){
			return 1;
		}
	}
	return x.walkLength - y.walkLength;
}
struct CitserverAPI{
	import std.net.curl;
	import std.json;
	import std.algorithm, std.range;
	import std.regex;

	this(string _apiRoot){
		apiRoot = _apiRoot;
	}
	public string apiRoot;

	public auto IDs(){
		return getIndexNode.object.byKey;
	}
	public auto versions(string id){
		return getIndexNode[id].object.byKey
					.filter!(a => a.isMatch(ctRegex!(`^[0-9\.]+$`)));
	}
	public string latestVersion(string id){
		return this.versions(id)
					.maxCount!((a, b) => cmpVersion(a, b) < 0)()[0];
	}
	public auto versionInfo(string id, string ver){
		return getIndexNode[id][ver];
	}
	public auto fileList(string id, string ver){
		import std.string;
		return std.net.curl.get([this.apiRoot, id, ver~".json"].join("/"))
					.parseJSON()["files"].array;
	}

	private JSONValue getIndexNode(){
		return std.net.curl.get(this.apiRoot~"/index.json")
					.parseJSON();
	}
}
