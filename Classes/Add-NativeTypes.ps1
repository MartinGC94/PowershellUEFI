Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Text;
  
public class PowershellUefiNative
{
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern UInt32 GetFirmwareEnvironmentVariable(string lpName, string lpGuid, [Out] Byte[] lpBuffer, UInt32 nSize);
    
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern UInt32 SetFirmwareEnvironmentVariable(string lpName, string lpGuid, Byte[] lpBuffer, UInt32 nSize);
    
    [DllImport("ntdll.dll", EntryPoint="RtlAdjustPrivilege")]
    public static extern int RtlAdjustPrivilege(ulong Privilege, bool Enable, bool CurrentThread, ref bool Enabled);
}
'@