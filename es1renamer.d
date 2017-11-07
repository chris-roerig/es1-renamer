import std.algorithm;
import std.array;
import std.exception;
import std.file;
import std.format;
import std.path;
import std.range : empty;
import std.stdio;
import std.uni;

void main()
{
  string packName;
  string outpath;

  write("Sample pack name: ");
  readf("%s\n", &packName);
  outpath = "output/" ~ packName;

  createTargetDir(outpath);
  writeSampleMap(copySamples(outpath), outpath);

  writeln("DONE");
}

// http://soundfile.sapp.org/doc/WaveFormat/
bool is16Bit(string path) 
{
    auto file = File(path, "r");
    byte[] buffer;

    // bit rate is 2 bytes long
    buffer.length = 2;

    // 34 bytes is where the bit rate is stored
    file.seek(34, SEEK_SET);
    auto data = file.rawRead(buffer);
    file.close();

    return data[0] == 16;
}

// returns only 16 bit wav files found in the input folder
auto wavFiles()
{
  return dirEntries("input", SpanMode.depth)
          .filter!(a => toLower(extension(a)) == ".wav")
          .filter!(a => is16Bit(a));
}

string[] copySamples(string outpath)
{
  int i = 0;
  string[] rows;

  foreach (string name; wavFiles())
  {
    string outfile = format(outpath ~"/%02d.wav", i);
    
    // copy file to target
    try
    {
      copy(name, outfile);
      writeln(name, " -----> ", outfile);
      rows ~= baseName(name) ~ "," ~ baseName(outfile);
      i++;
    }
    catch (FileException e) 
    {
      writeln("Failed to copy ", name, ": ", e.msg);
    }
  }

  return rows;
}

void createTargetDir(string outpath)
{
  try
  {
    mkdir(outpath);
  }
  catch (FileException e) 
  {
    writeln(e.msg);
  }
}

void writeSampleMap(string[] rows, string outpath)
{
  // create the sample map
  try
  {
    std.file.write(outpath ~ "/sample-map.csv", rows.join("\n"));
    writeln(outpath ~ "/sample-map.csv saved.");
  }
  catch (FileException e) 
  {
    writeln("Failed to save ", outpath, " sample-map.csv: ", e.msg);
  }
}
