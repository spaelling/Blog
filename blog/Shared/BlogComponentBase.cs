using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using Blog.Environment;
using MarkdownSharp;
using Microsoft.AspNetCore.Components;

namespace Blog.Shared
{
    public class BlogComponentBase : ComponentBase
    {
        [Inject]
        public List<GithubContent> blogposts { get; set; }
        [Inject]
        public HttpClient Http {get; set; }
        [Inject]
        public Configuration configuration {get; set; }

        public async Task initialize()
        {
            if(blogposts.Count == 0)
            {
                blogposts.AddRange(await Http.GetJsonAsync<GithubContent[]>(configuration.GithubContentUrl));
            }            
        }         
    }
}