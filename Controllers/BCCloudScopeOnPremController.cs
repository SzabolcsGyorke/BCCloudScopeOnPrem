    using Microsoft.AspNetCore.Mvc;
    using Newtonsoft.Json.Linq;
    using Newtonsoft.Json;
    using System.IO;
    using Microsoft.AspNetCore.Authorization;

    namespace BCCloudScopeOnPrem.Controllers;
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class BCCouldScopeOnPremController : ControllerBase
    {
        private readonly ILogger<BCCouldScopeOnPremController> _logger;

        public BCCouldScopeOnPremController(ILogger<BCCouldScopeOnPremController> logger)
        {
            _logger = logger;
        }

        [HttpPost]
        public string? SetRunFileFunction([FromBody]BCCommand bccommand)
        {
            var JsonResult = new Object();

            switch (bccommand.Action)
            {
                case "ls":
                    //to-do: check parameters
                BCLsResults bclsresults = new BCLsResults();
                try{
                    bclsresults.Files = Directory.GetFiles(bccommand.Parameter1,bccommand.Parameter2,(SearchOption)Enum.Parse(typeof(SearchOption), bccommand.Parameter3));
                } catch(Exception eee)
                {
                    JsonResult = JsonConvert.SerializeObject(new BCSimpleResult(false, eee.Message));
                    return JsonResult.ToString();
                }
                  bclsresults.Success = true;
                  JsonResult = JsonConvert.SerializeObject(bclsresults);
                  return JsonResult.ToString();
                case "exits":
                if (System.IO.File.Exists(bccommand.Parameter1))
                {
                        JsonResult = JsonConvert.SerializeObject(new BCSimpleResult(true, ""));
                        return JsonResult.ToString();
                }else
                {
                        JsonResult = JsonConvert.SerializeObject(new BCSimpleResult(false, ""));
                        return JsonResult.ToString();
                }

                case "upload":
                    if (System.IO.File.Exists(bccommand.Parameter1))
                    {
                        byte[] buffer;
                        FileStream fileStream = new FileStream(bccommand.Parameter1, FileMode.Open, FileAccess.Read);
                        try
                        {
                            int length = (int)fileStream.Length;  // get file length
                            buffer = new byte[length];            // create buffer
                            int count;                            // actual number of bytes read
                            int sum = 0;                          // total number of bytes read

                            // read until Read method returns 0 (end of the stream has been reached)
                            while ((count = fileStream.Read(buffer, sum, length - sum)) > 0)
                            sum += count;  // sum is a buffer offset for next reading
                        }
                        finally
                        {
                            fileStream.Close();
                        }
                        //base64 encode and pass back as result
                        BCFileContentResult returnfile = new BCFileContentResult();
                        returnfile.Success = true;
                        returnfile.Base64Value = Convert.ToBase64String(buffer, 0, buffer.Length);
                        JsonResult = JsonConvert.SerializeObject(returnfile);
                        

                        if (bccommand.Parameter2 == "delete") 
                        {
                            System.IO.File.Delete(bccommand.Parameter1);
                        }

                        if (bccommand.Parameter2 == "move") 
                        {
                            System.IO.File.Move(bccommand.Parameter1,bccommand.Parameter3);
                        }

                        return JsonResult.ToString();

                    } else 
                    {
                            JsonResult = JsonConvert.SerializeObject(new BCSimpleResult(false, ""));
                            return JsonResult.ToString();
                    }
                
                case "download":
                        try
                        {
                            System.IO.File.WriteAllBytes(bccommand.Parameter1, Convert.FromBase64String(bccommand.Parameter2));
                        }
                        catch (System.Exception eee)
                        {
                            JsonResult = JsonConvert.SerializeObject(new BCSimpleResult(false, eee.InnerException.Message));
                            return JsonResult.ToString();
                        }
                        
                        JsonResult = JsonConvert.SerializeObject(new BCSimpleResult(true, ""));
                            return JsonResult.ToString();
                        

                case "mkdir":
                try
                {
                    System.IO.Directory.CreateDirectory(bccommand.Parameter1);
                }
                catch (System.Exception eee)
                {
                    JsonResult = JsonConvert.SerializeObject(new BCSimpleResult(false, eee.InnerException.Message));
                    return JsonResult.ToString();
                }
                
                JsonResult = JsonConvert.SerializeObject(new BCSimpleResult(true, ""));
                    return JsonResult.ToString();


                case "erase":
                try
                {
                    System.IO.File.Delete(bccommand.Parameter1);
                }
                catch (System.Exception eee)
                {
                    JsonResult = JsonConvert.SerializeObject(new BCSimpleResult(false, eee.InnerException.Message));
                    return JsonResult.ToString();
                }
                
                JsonResult = JsonConvert.SerializeObject(new BCSimpleResult(true, ""));
                    return JsonResult.ToString();

                case "fileinfo":
                try
                {
                    DateTime dt = System.IO.Directory.GetLastWriteTime(bccommand.Parameter1);
                    FileInfo fi = new FileInfo(bccommand.Parameter1);
                    JsonResult = JsonConvert.SerializeObject(new BCFileInfoResult(true, dt, fi.Length));
                    return JsonResult.ToString();
                }
                catch (System.Exception eee)
                {
                    JsonResult = JsonConvert.SerializeObject(new BCSimpleResult(false, eee.InnerException.Message));
                    return JsonResult.ToString();
                }
                break;
               
                default:
                {
                    JsonResult = JsonConvert.SerializeObject(new BCSimpleResult(false, "Unknown command"));
                    return JsonResult.ToString();
                }
                    
            }
            JsonResult = JsonConvert.SerializeObject(new BCSimpleResult(false, "Unknown command"));
            return JsonResult.ToString();
        }

    
    }
