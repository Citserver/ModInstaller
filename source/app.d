import std.stdio;
import moddl.net;
import moddl.file;
import moddl.utils;
import moddl.api;
import std.algorithm, std.range, std.array;
import std.json;
import std.file;
import std.regex;

immutable fileListName = "currentFileList.json";
immutable apiRoot = "http://api.citringo.net/citserver/modpackage/v1/";
immutable serverID = "Citserver11";

void main(string[] args){
	if(!exists("./mods")) mkdir("mods");
	auto api = CitserverAPI(apiRoot);
	string ver = api.latestVersion(serverID);

	writeln("ModInstaller");
	writefln("id:%s", serverID);
	writefln("version:%s", ver);

	auto newList = api.fileList(serverID, ver).toFileList;
	auto currentList = currentFileList();

	auto addedFileNameList =  newList.byValue
														.filter!(a => a.name !in currentList || a != currentList[a.name])
														.map!(a => a.name)
														.cache;

	auto deletedFileNameList = currentList.byValue
														.filter!(a => a.name !in newList || a != newList[a.name])
														.map!(a => a.name)
														.cache;
	//削除する
	foreach(a; deletedFileNameList){
		auto file = currentList[a];
		file.name.writeln;
		file.path.writeln;
		if(exists(file.path)){
			if(isFile(file.path)){
				remove(file.path);
			}else{
				rmdirRecurse(file.path);
			}
		}
	}
	//追加する
	foreach(a; addedFileNameList){
		//落とす
		auto file = newList[a];
		auto dlfile = DownloadFile(file.from);
		if(file.referer != "") dlfile.referer = file.referer;
		dlfile.targetDirectory = file.to;

		file.fileName = dlfile.fileName;
		writefln("DownLoad %s(%s)", a, file.fileName);
		//file.path.writeln;
		dlfile.download();

		//unzipする
		if(file.unzip){
			writefln("Decompress %s", a);
			import std.zip, std.path;
			unzip(file.path);
			auto zipFilePath = file.path;

			file.fileName = (new ZipArchive(file.path.read)).directory.byValue.front.name.pathSplitter.front;

			remove(zipFilePath);
		}
		newList[a] = file;
	}

	//リストつくる
	auto newFileList = currentList.dup;
	foreach(a; deletedFileNameList){
		newFileList.remove(a);
	}
	foreach(a; addedFileNameList){
		newFileList[a] = newList[a];
	}
	JSONValue root;
	root["files"] = JSONValue(newFileList.toJSONValue);
	std.file.write(fileListName, (&root).toJSON);
}

FileList currentFileList(){
	if(exists(fileListName)){
		auto node = fileListName.readText.parseJSON();
		return node["files"].array.toFileList;
	}else{
		FileList a;
		return a;
	}
}

void unzip(string fileName){
	import std.zip;
	import std.path;
	import std.file;

	auto zip = new ZipArchive(fileName.read);
	auto target = dirName(fileName);
	foreach(de; zip.directory.byValue){
		import std.string;
		auto path = buildPath(target, de.name.split("/").buildPath);
		//path.writeln;

		if(!exists(path.dirName)) mkdirRecurse(path.dirName);

		zip.expand(de);

		if(!exists(path)){
			/*ファイルのパスであるか*/
			if(isMatch(path, regex(`\.[\w]+`))){
				auto file = new File(path, "wb+");
				file.write(de.expandedData);
				//de.name.writeln;
				file.close;
			}else{
				mkdirRecurse(path);
			}
		}
	}
}
