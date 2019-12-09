using System.Linq;

namespace blog.shared
{
    public class GithubContent
    {
        public string Name { get; set; }

        public string Path { get; set; }

        public string Download_url { get; set; }

        public int Year => int.Parse(Name.Split('-').First());

        public int Month => int.Parse(Name.Split('-').Skip(1).Take(1).First());

        public string Date => $"{Year}-{Month.ToString().PadLeft(2,'0')}";

        public string DisplayName => Name.Substring(0,Name.Length-3).Replace('-',' ');
    }
}