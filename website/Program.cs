using Microsoft.AspNetCore.StaticFiles;
using Microsoft.Extensions.FileProviders;

namespace planespheres;

public class Program
{
    public static void Main(string[] args)
    {
        CreateHostBuilder(args).Build().Run();
    }

    public static IHostBuilder CreateHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
        .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                });
}

public class Startup
{
    public Startup(IConfiguration configuration, IWebHostEnvironment env)
    {
        Configuration = configuration;
        CurrentEnvironment = env;
    }

    private IWebHostEnvironment CurrentEnvironment { get; set; }
    public IConfiguration Configuration { get; }

    // This method gets called by the runtime. Use this method to add services to the container.
    public void ConfigureServices(IServiceCollection services)
    {

        services.AddControllersWithViews();
        services.AddRazorPages();
    }

    // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
        if (env.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
            app.UseHttpsRedirection();
        }
        else
        {
            app.UseExceptionHandler("/Home/Error");
            // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
            app.UseHsts();
        }
        app.UseRouting();

        // Grab the path to our web-build, somewhere in the nix-store
        var webBuildPath = System.Environment.GetEnvironmentVariable("WEB_BUILD_PATH");

        // A new file provider that points to our web build
        IFileProvider? webBuildProvider = null;

        // If that path exits serve it
        if (webBuildPath is not null)
        {
            // Point to the web build in the nix-store
            webBuildProvider = new PhysicalFileProvider(webBuildPath);
        }
        // Otherwise
        else
        {
            // Location we expect a version of the web build to be during development
            string devGameBuildPath = env.WebRootPath + "/result/share/PlaneSpheres/";

            // Check if the system link to the build exists
            if (Directory.Exists(devGameBuildPath))
                //point to a backup build in wwwroot/result, helpful for development
                webBuildProvider = new PhysicalFileProvider(devGameBuildPath);
            else
                logger.LogWarning("Web build not present in wwwroot. Run 'nix build .#web-build' inside wwwroot to serve web build during development");
        }

        if (webBuildProvider is not null)
        {
            // Lets us map content types for files with none standard extensions
            var godotContentTypes = new FileExtensionContentTypeProvider();

            // ensure that these files are delivered with correct MIME type
            godotContentTypes.Mappings[".pck"] = "application/octet-stream";
            godotContentTypes.Mappings[".wasm"] = "application/wasm";

            // serve static files and pass in options
            app.UseStaticFiles(new StaticFileOptions
            {
                // Server static files using our web build provider
                FileProvider = webBuildProvider,

        // TODO: Remove this. Here just for debugging, helps me confirm web build is being served
        app.UseDirectoryBrowser(new DirectoryBrowserOptions
        {
            FileProvider = webBuildProvider,
            RequestPath = new PathString("/look")
        });
                // The endpoint mapping to our web build directory
                RequestPath = new PathString("/web-build"),

                // Make sure they are served with the right MIME type
                ContentTypeProvider = godotContentTypes,

                // before serving the files make changes to the response
                OnPrepareResponse = ctx =>
                {
                    // headers that are required while serving Godot web-build
                    ctx.Context.Response.Headers.Append("Cross-Origin-Opener-Policy", "same-origin");
                    ctx.Context.Response.Headers.Append("Cross-Origin-Embedder-Policy", "require-corp");
                    ctx.Context.Response.Headers.Append("Access-Control-Allow-Origin", "*");
                }
            });
        }

        // Path to materials/assets used to build plane-spheres
        var materialsPath = System.Environment.GetEnvironmentVariable("MATERIALS_PATH");

        // If that path exits serve it
        if (materialsPath is not null)
        {
            // Point to the data in the nix-store
            var materialsFileProvider = new PhysicalFileProvider(materialsPath);

            // serve static files and pass in options
            app.UseStaticFiles(new StaticFileOptions
            {
                // Server static files using our web build provider
                FileProvider = materialsFileProvider,

                // The endpoint mapping to our web build directory
                RequestPath = new PathString("/materials"),
            });
        }

        // serves /wwwroot
        app.UseStaticFiles();

        app.UseEndpoints(endpoints =>
                {
                    endpoints.MapControllerRoute(
                            name: "default",
                            pattern: "{controller=Home}/{action=Index}/{id?}"
                            );
                    endpoints.MapRazorPages();
                });
    }
}
