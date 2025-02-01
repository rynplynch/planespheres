using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using planespheres.Controllers;

namespace planespheres.ViewComponents
{
    public class GameViewComponent : ViewComponent
    {
        private readonly ILogger<GameViewComponent> _logger;

        public GameViewComponent(
            ILogger<GameViewComponent> logger
        )
        {
            _logger = logger;
        }

        public IViewComponentResult Invoke()
        {
            return View();
        }
    }
}
