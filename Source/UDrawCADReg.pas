unit UDrawCadReg;

interface

uses Windows, Classes,
     UdCmdLine, UdDrawPanel, //UdDocument,
	   UdLayerComboBox, UdColorComboBox, UdLntypComboBox, UdLwtComboBox;


procedure Register;


implementation


procedure Register;
begin
  //RegisterComponents('DelphiCAD', [TUdDocument]);
  RegisterComponents('DelphiCAD', [TUdCmdLine]);
  RegisterComponents('DelphiCAD', [TUdDrawPanel]);

//  RegisterComponents('DelphiCAD', [TUdLayerComboBox]);
//  RegisterComponents('DelphiCAD', [TUdColorComboBox]);
//  RegisterComponents('DelphiCAD', [TUdLntypComboBox]);
//  RegisterComponents('DelphiCAD', [TUdLwtComboBox]);
end;

end.