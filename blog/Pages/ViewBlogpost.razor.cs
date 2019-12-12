using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using Blog.Shared;
using MarkdownSharp;
using Microsoft.AspNetCore.Components;

namespace Blog.Pages
{
    public class ViewBlogpost2 : BlogComponentBase
    {
        private readonly Markdown markdown = new Markdown();
        private int index => int.Parse(Index);
        private GithubContent blogpost;

        [Parameter]
        public string Index { get; set; }

        public string Title { get; set; }

        public string Content { get; set; }

        protected override async Task OnInitializedAsync()
        {
            await initialize();

            blogpost = blogposts[index];
            Title = blogpost.DisplayName;

            var rawmarkdown = await Http.GetStringAsync(blogpost.Download_url);
            Content = markdown.Transform(rawmarkdown);
        }        
    }
}
