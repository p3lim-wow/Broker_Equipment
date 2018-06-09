Set-Location -Path "$PSScriptRoot\.."

If(-Not (Test-Path -Path "libs")){
	New-Item -ItemType Directory -Path libs
}

If(-Not (Test-Path -Path "libs\LibStub")){
	New-Item -ItemType SymbolicLink -Path "libs" -Name LibStub -Value ..\LibStub
} ElseIf(-Not (((Get-Item -Path "libs\LibStub").Attributes.ToString()) -Match "ReparsePoint")){
	Remove-Item -Path "libs\LibStub"
	New-Item -ItemType SymbolicLink -Path "libs" -Name LibStub -Value ..\LibStub
}

If(-Not (Test-Path -Path "libs\CallbackHandler-1.0")){
	New-Item -ItemType SymbolicLink -Path "libs" -Name CallbackHandler-1.0 -Value ..\CallbackHandler-1.0
} ElseIf(-Not (((Get-Item -Path "libs\CallbackHandler-1.0").Attributes.ToString()) -Match "ReparsePoint")){
	Remove-Item -Path "libs\CallbackHandler-1.0"
	New-Item -ItemType SymbolicLink -Path "libs" -Name CallbackHandler-1.0 -Value ..\CallbackHandler-1.0
}

If(-Not (Test-Path -Path "libs\LibDataBroker-1.1")){
	New-Item -ItemType SymbolicLink -Path "libs" -Name LibDataBroker-1.1 -Value ..\LibDataBroker-1.1
} ElseIf(-Not (((Get-Item -Path "libs\LibDataBroker-1.1").Attributes.ToString()) -Match "ReparsePoint")){
	Remove-Item -Path "libs\LibDataBroker-1.1"
	New-Item -ItemType SymbolicLink -Path "libs" -Name LibDataBroker-1.1 -Value ..\LibDataBroker-1.1
}
