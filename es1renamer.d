import std.stdio;
import std.exception;
import std.file;
import std.path;
import std.format;
import std.range : empty;

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

bool isWav(string path)
{
  return extension(path) == ".wav";
}

void main()
{
  string[] files;

  int i = 0;
  foreach (string name; dirEntries("input", SpanMode.depth))
  {
    if(!isWav(name))
    {
      continue;
    }

    if(!is16Bit(name))
    {
      writeln("Skipping ", name, " (not 16 bit)");
      continue;
    }

    string outfile = format("output/%02d.wav", i);
    
    try
    {
      copy(name, outfile);
      writeln(name, " -----> ", outfile);
    }
    catch (FileException ex) 
    {
      writeln("Failed to copy ", name);
    }
  }
}
