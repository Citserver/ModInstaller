module moddl.file;

import std.json;

struct FileListElement{
	string name;
	string from;
	//ここまで必須
	string to;
	string referer;
	bool unzip;

	string fileName;

	bool opEquals(FileListElement e){
		return	this.name	== e.name &&
						this.from	== e.from	&&
						this.to		== e.to		&&
						this.unzip == e.unzip &&
						this.referer == e.referer;
	}

	@property string path(){
		import std.path;
		return buildPath(to, fileName);
	}
}

alias FileList = FileListElement[string];

FileList toFileList(JSONValue[] list){
	import std.algorithm, std.array;
	import std.typecons;
	import std.json;
	return list.map!(
		(a){
			bool isValid(string a0, JSON_TYPE a1, JSONValue b){
				return a0 in b.object && b[a0].type == a1;
			}
			assert(
				[
					tuple("name", JSON_TYPE.STRING),
					tuple("from", JSON_TYPE.STRING)
				].all!(p => isValid(p[0], p[1], a))
			);
			FileListElement b;
			b.name = a["name"].str;
			b.from = a["from"].str;
			if(isValid("to", JSON_TYPE.STRING, a)){
				b.to = a["to"].str;
			}else{
				b.to = ".";
			}
			if(isValid("referer", JSON_TYPE.STRING, a)){
				b.referer = a["referer"].str;
			}else{
				b.referer = "";
			}
			if(isValid("unzip", JSON_TYPE.TRUE, a)){
				b.unzip = true;
			}else{
				b.unzip = false;
			}
			if(isValid("fileName", JSON_TYPE.STRING, a)){
				b.fileName = a["fileName"].str;
			}

			return tuple(b.name, b);
		}
	).assocArray;
}

JSONValue[] toJSONValue(FileList list){
	import std.algorithm, std.array;
	import std.json;
	return list.byValue.map!(
		(a){
			JSONValue b = [
				"name":a.name,
				"from":a.from,
				"to":a.to,
				"referer":a.referer,
				"fileName":a.fileName
			];
			b["unzip"] = JSONValue(a.unzip);
			return b;
		}
	).array;
}
