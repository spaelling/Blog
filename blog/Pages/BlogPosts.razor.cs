using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using Blog.Shared;
using MarkdownSharp;
using Microsoft.AspNetCore.Components;

namespace Blog.Pages
{
    public class BlogPosts2 : BlogComponentBase
    {
       
        protected override async Task OnInitializedAsync()
        {
            await initialize();
            // string GithubContentUrl = "https://api.github.com/repos/spaelling/blog/contents/blogposts";
            // if(blogposts.Count == 0)
            // {
            //     blogposts.AddRange(await Http.GetJsonAsync<GithubContent[]>(GithubContentUrl));
            // }
        }
        protected string GetIndex(GithubContent content)
        {
            return $"{blogposts.IndexOf(content)}";
        }        
    }
}