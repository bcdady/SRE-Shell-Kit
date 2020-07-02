using Amazon.Lambda.PowerShellHost;

namespace Project
{
    public class Bootstrap : PowerShellFunctionHost
    {
        public Bootstrap() : base("BasicTemplate.ps1")
        {
        }
    }
}
