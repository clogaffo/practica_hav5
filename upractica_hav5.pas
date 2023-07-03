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
    btRespuesta: TButton;
    btCorrecto: TButton;
    btIncorrecto: TButton;
    btTerminar: TButton;
    btComenzar: TButton;
    Image1: TImage;
    lbInfo: TLabel;
    lbRespuesta: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure btComenzarClick(Sender: TObject);
    procedure btIncorrectoClick(Sender: TObject);
    procedure btRespuestaClick(Sender: TObject);
    procedure btCorrectoClick(Sender: TObject);
    procedure btTerminarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure muestraimagen(i:integer);
    procedure siguienteimagen;
    procedure ActualizaInfo;
    procedure generaPendientes;
  private
    listaImagenes: TStringList;
    imagenesPendientes: array of integer;
    respuestasCorrectas: array of integer;
    respuestasIncorrectas: array of integer;
    respuestasRepaso: array of integer;
    imagenact:string;
    indiceact:integer;
    indicerepaso:integer;
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
  indicerepaso := -1;
  btCorrecto.Enabled := False;
  btIncorrecto.Enabled := False;
  lbRespuesta.Caption := '';
  muestraimagen(RandomImage);
  ActualizaInfo;
  btRespuesta.Enabled := True;
end;

procedure TForm1.muestraimagen(i: integer);
var
  png : TPNGImage;
  pngw,pngh,imgw,imgh: integer;
  dest: TRect;
begin
  png := TPNGImage.Create;
  try
    indiceact := i;
    imagenact := listaImagenes[i];
    png.LoadFromFile(imagenact);
    pngw := png.Width;
    pngh := png.Height;
    imgw := Image1.Width;
    imgh := Image1.Height;

    if pngh/pngw>imgh/imgw then
    begin
      dest.Top := 0;
      dest.Bottom := imgh;
      dest.Left := (imgw - (pngw * imgh div pngh)) div 2;
      dest.Right := (pngw * imgh div pngh) + dest.Left;
    end
    else
    begin
      dest.Left := 0;
      dest.Right := imgw;
      dest.Top := (imgh - (pngh * imgw div pngw)) div 2;
      dest.Bottom := (pngh * imgw div pngw) + dest.Top;
    end;

    Image1.Canvas.Clear;
    Image1.Canvas.StretchDraw(dest,png);
  finally
    FreeAndNil(png);
  end;
end;

procedure TForm1.siguienteimagen;
var
  cand: integer;
  candok: boolean;
  i: integer;
begin
  btCorrecto.Enabled := False;
  btIncorrecto.Enabled := False;
  lbRespuesta.Caption := '';
  if indicerepaso<0 then
  begin
    if length(imagenesPendientes)<1 then
    begin
      ShowMessage('ESTUDIO TERMINADO');
      generaPendientes;
      Exit;
    end;

   cand := RandomImage;
  end
  else
  begin
    if indicerepaso>high(respuestasRepaso) then
    begin
      ShowMessage('REPASO TERMINADO');
      indicerepaso := -1;
      Exit;
    end;
    cand := respuestasRepaso[indicerepaso];
    inc(indicerepaso);
  end;
  muestraimagen(cand);
  ActualizaInfo;
  btRespuesta.Enabled := True;
end;

procedure TForm1.ActualizaInfo;
var
 s: string;
begin
  s:=inttostr(indiceact)+' ';
  if indicerepaso<0 then
  begin
    s := s+ 'General  ';
    s := s+'Faltantes: '+inttostr(length(imagenesPendientes));
  end
  else
  begin
    s := s+ 'Repaso  ';
    s := s+'Faltantes: '+inttostr(length(respuestasRepaso)-length(respuestasCorrectas)-length(respuestasIncorrectas));
  end;
  s := s+' Correctas: '+inttostr(length(respuestasCorrectas))+' Incorrectas: '+inttostr(length(respuestasIncorrectas));
  lbInfo.Caption:=s;
end;

procedure TForm1.generaPendientes;
var
  i:integer;
begin
  setlength(imagenesPendientes,listaImagenes.Count);
  for i:=0 to high(imagenesPendientes) do
    imagenesPendientes[i] := i;
end;

function TForm1.RandomImage: integer;
var
  i,idxrst: integer;
begin
  idxrst := Round(Random()*high(imagenesPendientes));
  Result := imagenesPendientes[idxrst];
  for i:=idxrst to high(imagenesPendientes)-1 do
    imagenesPendientes[idxrst] := imagenesPendientes[idxrst+1];
  setlength(imagenesPendientes,length(imagenesPendientes)-1);
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
  while listaImagenes.Count>10 do
    listaImagenes.Delete(10);
  Randomize;
  generaPendientes;
end;

procedure TForm1.btCorrectoClick(Sender: TObject);
begin
  SetLength(respuestasCorrectas,length(respuestasCorrectas)+1);
  respuestasCorrectas[high(respuestasCorrectas)] := indiceact;
  siguienteimagen;
end;

procedure TForm1.btTerminarClick(Sender: TObject);
var
  i:integer;
begin
  if length(respuestasIncorrectas)>0 then
  begin
    if MessageDlg('Desea realizar un repaso de las que respondio incorrectamente?',mtConfirmation,[mbYes, mbNo],0)=mrYes then
    begin
      setlength(respuestasRepaso,length(respuestasIncorrectas));
      for i:=0 to high(respuestasIncorrectas) do
         respuestasRepaso[i]:=respuestasIncorrectas[i];
      setlength(respuestasCorrectas,0);
      setlength(respuestasIncorrectas,0);
      indicerepaso := 0;
      siguienteimagen;
      exit;
    end
  end;
  setlength(respuestasCorrectas,0);
  setlength(respuestasIncorrectas,0);
  setlength(respuestasRepaso,0);
  btTerminar.Visible:=False;
  btComenzar.Visible:=True;
end;

procedure TForm1.btRespuestaClick(Sender: TObject);
begin
  btRespuesta.Enabled := False;
  lbRespuesta.Caption := AnsiReplaceStr(AnsiReplaceStr(copy(imagenact,1,length(imagenact)-4),PathDelim,' - '),'imagenes -','');
  btCorrecto.Enabled := True;
  btIncorrecto.Enabled := True;
end;

procedure TForm1.btIncorrectoClick(Sender: TObject);
begin
  SetLength(respuestasIncorrectas,length(respuestasIncorrectas)+1);
  respuestasIncorrectas[high(respuestasIncorrectas)] := indiceact;
  siguienteimagen;
end;

procedure TForm1.btComenzarClick(Sender: TObject);
begin
  btTerminar.Visible:=True;
  btComenzar.Visible:=False;
  siguienteimagen;
end;

end.

