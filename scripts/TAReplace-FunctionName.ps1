using namespace System;
using namespace System.Collections.Generic;
using namespace System.Text.RegularExpressions;

# Write-Verbose -Message 'Get file content.';
[String]$file_name = 'CdlIdentical3Crows';
[String]$file_path = '.\src\ta\func\' + $file_name + '.hx';
[String]$source = Get-Content -Path $file_path -Raw;

# Write-Verbose -Message 'Replace `TA_CANDLEAVGPERIOD(arg)` to `Globals.candleSettings[arg].avgPeriod`.';
$source = [Regex]::Replace($source, 'TA_CANDLEAVGPERIOD\((?<type_name>\w*?)\)', 'Globals.candleSettings[${type_name}].avgPeriod');
# Write-Verbose -Message 'Append `CandleSettingType.`.';
$source = [Regex]::Replace($source, '(?<!\.)(?=(?:BodyLong|BodyVeryLong|BodyShort|BodyDoji|ShadowLong|ShadowVeryLong|ShadowShort|ShadowVeryShort|Near|Far|Equal|AllCandleSettings)\b)', 'CandleSettingType.');
# Replace `VALUE_HANDLE_DEREF_TO_ZERO(arg)` to `arg = 0`.
$source = [Regex]::Replace($source, 'VALUE_HANDLE_DEREF_TO_ZERO\((?<arg_name>\w*?)\)', '${arg_name} = 0');
# Replace `VALUE_HANDLE_DEREF(arg)` to `arg`.
$source = [Regex]::Replace($source, 'VALUE_HANDLE_DEREF\((?<arg_name>\w*?)\)', '${arg_name}');

$source = [Regex]::Replace($source, 'LOOKBACK_CALL\(\w*?\)', ($file_name + 'Lookback'));

# Replace `Idx` to `Index` and `ENUM_VALUE(RetCode,TA_SUCCESS,Success)` to `{key:value}`;
$source = $source.Replace('Idx', 'Index');
$source = $source.Replace('ENUM_VALUE(RetCode,TA_SUCCESS,Success)', @'
{
    outBegIndex: outBegIndex,
    outNBElement: outNBElement,
    outInteger: outInteger
}
'@);

[Dictionary[String, String[]]]$func_names = [Dictionary[[String], String[]]]::new();
$func_names.Add('RealBody', @('inOpen', 'inClose'));
$func_names.Add('UpperShadow', @('inOpen', 'inHigh', 'inClose'));
$func_names.Add('LowerShadow', @('inOpen', 'inLow', 'inClose'));
$func_names.Add('HighLowRange', @('inHigh', 'inLow'));
$func_names.Add('CandleColor', @('inOpen', 'inClose'));
$func_names.Add('CandleRange', @('inOpen', 'inHigh', 'inLow', 'inClose'));
$func_names.Add('CandleAverage', @('inOpen', 'inHigh', 'inLow', 'inClose'));
$func_names.Add('RealBodyGapUp', @('inOpen', 'inClose'));
$func_names.Add('RealBodyGapDown', @('inOpen', 'inClose'));
$func_names.Add('CandleGapUp', @('inHigh', 'inLow'));
$func_names.Add('CandleGapDown', @('inHigh', 'inLow'));
# Write-Verbose -Message 'Replace `TA_MACRO` to `Utility` function.';
$func_names.Keys | ForEach-Object -Process {
    $oragin_name = 'TA_' + $_.ToUpper();
    $source = [Regex]::Replace($source, $oragin_name + '\((?<oragin_args>(?:[^\(\)]|\(.*?\))*?)\)', "$_(`${oragin_args}, $([String]::Join(', ', $func_names[$_])))");
};

# Write-Verbose -Message 'Write replaced content to file.';
Set-Content -Path $file_path -Value $source | Out-Null;

Write-Host -Message 'All done!' -ForegroundColor Green | Out-Null;
