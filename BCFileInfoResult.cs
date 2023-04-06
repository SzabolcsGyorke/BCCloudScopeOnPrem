namespace BCCloudScopeOnPrem;

public class BCFileInfoResult
{
    public BCFileInfoResult(bool success, DateTime filelastwritedatetime, Int128 filesize)
    {
      Success = success;
      FileLastWriteDateTime = filelastwritedatetime;
      FileSize = filesize;
    }
   public bool Success { get; set; }
   public DateTime FileLastWriteDateTime { get; set; }
   public Int128 FileSize {get; set;}
}
