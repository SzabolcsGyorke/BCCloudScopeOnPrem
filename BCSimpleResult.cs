namespace BCCloudScopeOnPrem;

public class BCSimpleResult
{
    public BCSimpleResult(bool success, string errormessage)
    {
      Success = success;
      ErrorMessage = errormessage;
    }
   public bool Success { get; set; }
   public string? ErrorMessage { get; set; }
   
}
