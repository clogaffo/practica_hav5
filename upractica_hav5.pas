unit upractica_hav5;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  ExtCtrls,
  StdCtrls,
  StrUtils,
  lazpng;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    Label1: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure muestraimagen(i:integer);
  private
    listaImagenes: TStringList;
    imagenact:string;
    function RandomImage: integer;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}



{ TForm1 }

procedure TForm1.FormShow(Sender: TObject);
begin
  Button1.Enabled := True;
  Button2.Enabled := False;
  muestraimagen(RandomImage);
end;

procedure TForm1.muestraimagen(i: integer);
var
  png : TPNGImage;
  dest: TRect;
begin
  png := TPNGImage.Create;
  try
    imagenact := listaImagenes[i];
    png.LoadFromFile(imagenact);
    if png.Height div png.Width>Image1.Height div Image1.Width then
    begin
      dest.Top := 0;
      dest.Bottom := Image1.Height;
      dest.Left := (Image1.Width - (png.Width * Image1.Height div Image1.Width)) div 2;
      dest.Right := (png.Width * Image1.Height div Image1.Width) + dest.Left;
    end
    else
    begin
      dest.Left := 0;
      dest.Right := Image1.Width;
      dest.Top := (Image1.Height - (png.Height * Image1.Width div Image1.Height)) div 2;
      dest.Bottom := (png.Height * Image1.Width div Image1.Height) + dest.Top;
    end;

    Image1.Canvas.Clear;
    Image1.Canvas.StretchDraw(dest,png);
  finally
    FreeAndNil(png);
  end;
end;

function TForm1.RandomImage: integer;
begin
  Result := Round(Random()*listaimagenes.Count-1);
end;

procedure TForm1.FormCreate(Sender: TObject);
  procedure listadir(d:string);
  var
    SR: TSearchRec;
  begin
    if FindFirst(d+PathDelim+'*',faAnyFile,SR)=0 then
    begin
      repeat
        if pos('.',SR.Name)=1 then
          continue
        else if SR.Attr and faDirectory<>0 then
          listadir(d+PathDelim+SR.Name)
        else if pos('.png',SR.Name)>0 then
          listaImagenes.Add(d+PathDelim+SR.Name);
      until FindNext(SR)<>0;
      FindClose(SR);
    end;
  end;

begin
  listaImagenes := TStringList.Create;
  listadir('imagenes');
  if listaImagenes.Count=0 then
    ShowMessage('NO SE ENCONTRARON IMAGENES');
  Randomize;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Button1.Enabled := True;
  Button2.Enabled := False;
  Label1.Caption := '';
  muestraimagen(RandomImage);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Button1.Enabled := False;
  Button2.Enabled := True;
  Label1.Caption := AnsiReplaceStr(AnsiReplaceStr(extractFileDir(imagenact),PathDelim,' - '),'imagenes -','');
end;

end.

