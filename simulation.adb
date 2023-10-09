with Ada.Text_IO; 
use Ada.Text_IO;
with Ada.Integer_Text_IO; 
with Ada.Numerics.Discrete_Random;
with Ada.Exceptions;

procedure simulation is
    
   subtype ZakresWielkosciDostawy is  integer range 5 .. 10;
   package LosowanieWielkosciDostawy is new Ada.Numerics.Discrete_Random(ZakresWielkosciDostawy);
   
   subtype LosProdukcji is integer range 0 .. 2;
   package LosowanieProdukcji is new Ada.Numerics.Discrete_Random(LosProdukcji);
   
   subtype LosWypisuStanu is integer range 0 .. 10;
   package LosowanieWypisuStanu is new Ada.Numerics.Discrete_Random(LosWypisuStanu);
   
   package Wyjatki is
      brakSkladnika : exception;
   end Wyjatki;

   task Piekarnia;
   task Dostawca;
     
   task Kuchnia;
   task Kelner;
   task Rachunek;
   
   task body Piekarnia is
      ID : character := 'P';
      ilosc : integer;
      Losowacz : LosowanieWielkosciDostawy.Generator;
   begin
      LosowanieWielkosciDostawy.Reset(Losowacz);
      delay 1.5;
      loop
         begin
            ilosc := LosowanieWielkosciDostawy.Random(Losowacz);
            Kuchnia.przyjecieDostawy(ID, ilosc);
            delay 15.0;
         end;
      end loop; 
   end Piekarnia;
   
   task body Dostawca is
      ID : character := 'D';
      ilosc : integer;
      Losowacz : LosowanieWielkosciDostawy.Generator;
   begin
      LosowanieWielkosciDostawy.Reset(Losowacz);
      delay 2.5;
      loop
         begin
            ilosc := LosowanieWielkosciDostawy.Random(Losowacz);
            Kuchnia.przyjecieDostawy(ID, ilosc);       
            delay 12.0;
         end;
      end loop; 
   end Dostawca;
   
   task body Kuchnia is
      ID1 : character := 'S';
      ID2 : character := 'P';
      ilosc : integer;
      Losowacz : LosowanieWielkosciDostawy.Generator;
   begin
      LosowanieWielkosciDostawy.Reset(Losowacz);
      delay 0.5;
      loop
         begin
            ilosc := LosowanieWielkosciDostawy.Random(Losowacz);
            Rachunek.przyjecieDostawy(ID1, ilosc);
            ilosc := LosowanieWielkosciDostawy.Random(Losowacz);
            Rachunek.przyjecieDostawy(ID2, ilosc); 
            delay 10.0;
         end;
      end loop;
   end Kuchnia;
   
   task body Kelner is
      ID : character := 'K';
      ilosc : integer := 5;
   begin
      loop
         delay 6.0;
         Rachunek.sprzedaz(ID, ilosc);
         delay 6.0;
      end loop;
   end Kelner;
   
   task body Rachunek is
      ID : character := 'R';
      ilosc : integer := 5;
   begin
      loop
         delay 15.0;
         Rachunek.sprzedaz(ID, ilosc);
         delay 15.0;
      end loop;
   end Rachunek;
   
   task body Maszyna is
      los : integer;
      losowacz : LosowanieProdukcji.generator;
   begin
      LosowanieProdukcji.Reset(losowacz);
      loop
         los := LosowanieProdukcji.Random(losowacz);
         if los = 0 then --produkcja pizzy
            put_line("Rozpoczeto przygotowywanie pizzy");
            delay 3.0;
            Rachunek.produkcja('P');          
         elsif los = 1 then --produkcja napojow
            put_line("Rozpoczeto przygotowywanie napojow");
            delay 8.0;
            Rachunek.produkcja('N');
         elsif los = 2 then -- produkcja deserow
            put_line("Rozpoczeto przygotowywanie deserow");
            delay 3.0;
            Rachunek.produkcja('D');
         end if; 
      end loop;
   end Maszyna;
   
   task body Rachunek is
      iloscMaki : integer := 10;
      iloscPomidora : integer := 10;
      iloscSeru : integer := 10;
      iloscCiasta : integer := 10;
      
      iloscPizzy : integer := 0;
      iloscNapojow : integer := 0;
      iloscDeserow : integer := 0;
      
      iloscNieudanychWstawien : integer := 0;
      
      pojemnoscMagazynu : constant integer := 100;
      
      losWypisu : integer;
      Losowacz : LosowanieWypisuStanu.Generator;
      
      function sprawdzMiejscewMagazynie return integer is
      begin
         return pojemnoscMagazynu-iloscMaki-iloscPomidora-iloscSeru-iloscCiasta-iloscPizzy-iloscNapojow-iloscDeserow;
      end sprawdzMiejscewMagazynie;

      procedure wypiszStanMagazynu is
      begin
         New_Line;
         put_line("STAN MAGAZYNU");
         put_line("SKLADNIKI: Maka: " & Integer'Image(iloscMaki) & " Pomidor: " & Integer'Image(iloscPomidora) & " Ser: " 
                  & Integer'Image(iloscSeru) & " Ciasto: " & Integer'Image(iloscCiasta));
         put_line("MENU: Pizza: " & Integer'Image(iloscPizzy) & " Napoje: " & Integer'Image(iloscNapojow) & " Desery: " 
                  & Integer'Image(iloscDeserow));
         put_line("ZAPELNIENIE MAGAZYNU: " & Integer'Image(pojemnoscMagazynu-sprawdzMiejscewMagazynie) & "/" & Integer'Image(pojemnoscMagazynu));
         New_Line;
      end wypiszStanMagazynu;
      
      procedure brakSkladnika is
      begin
         if iloscNieudanychWstawien >= 5
            then
               raise Wyjatki.brakSkladnika with "BRAK SKLADNIKOW! ZAMOWIENIA MOGA BYC OPOZNIONE!";
         end if;
      end brakSkladnika;
     
   begin
      LosowanieWypisuStanu.Reset(losowacz);
      loop
         select
            accept przyjecieDostawy (ID: in character; ilosc: in integer) do
               if sprawdzMiejscewMagazynie >= ilosc then
                  if ID = 'P' then
                     iloscMaki := iloscMaki + ilosc;
                     put_line("Przyjechala dostawa maki w ilosci " & Integer'Image(ilosc));
                  elsif ID = 'T' then
                     iloscPomidora := iloscPomidora + ilosc;
                     put_line("Przyjechala dostawa pomidorow w ilosci " & Integer'Image(ilosc));
                  elsif ID = 'S' then
                     iloscSeru := iloscSeru + ilosc;
                     put_line("Przyjechala dostawa sera w ilosci " & Integer'Image(ilosc));
                  elsif ID = 'C' then
                     iloscCiasta := iloscCiasta + ilosc;
                     put_line("Przyjechala dostawa ciasta w ilosci " & Integer'Image(ilosc));
                  end if;
               else
                  put_line("BRAK MIEJSCA W MAGAZYNIE SKLADNIKOW! NIE PRZYJETO DOSTAWY");
                  iloscNieudanychWstawien := iloscNieudanychWstawien + 1;
               end if;               
            end przyjecieDostawy;
         or
            accept sprzedaz (ID: in character; ilosc : in integer) do
               if ID = 'P' then --sprzedaZ pizzy
                  if iloscPizzy >= ilosc then
                     iloscPizzy := iloscPizzy - ilosc;
                     put_line("Kelner sprzedal " & Integer'Image(ilosc) & " pizz");
                  else
                     put_line("Brak pizz do sprzedania kelnerowi!");
                  end if;
               elsif ID = 'N' then --sprzedaZ napojow
                  if iloscNapojow >= ilosc then
                     iloscNapojow := iloscNapojow - ilosc;
                     put_line("Rachunek sprzedal " & Integer'Image(ilosc) & " napojow");
                  else
                     put_line("Brak napojow do sprzedania rachunkowi!");
                  end if;
               elsif ID = 'D' then --sprzedaZ deserow
                  if iloscDeserow >= ilosc then
                     iloscDeserow := iloscDeserow - ilosc;
                     put_line("Rachunek sprzedal " & Integer'Image(ilosc) & " deserow");
                  else
                     put_line("Brak deserow do sprzedania rachunkowi!");
                  end if;
               end if;
            end sprzedaz;
         or
            accept produkcja (ID: character) do
               if sprawdzMiejscewMagazynie >= 5 then
                  if ID = 'P' then
                     if iloscMaki >= 1 and iloscPomidora >= 1 and iloscSeru >= 1 and iloscCiasta >= 1 then
                        iloscMaki := iloscMaki - 1;
                        iloscPomidora := iloscPomidora - 1;
                        iloscSeru := iloscSeru - 1;
                        iloscCiasta := iloscCiasta - 1;
                        iloscPizzy := iloscPizzy + 1;
                        put_line("Przygotowano 1 pizze");
                     else
                        put_line("BRAK SKLADNIKOW DO PRODUKCJI PIZZY!");
                        brakSkladnika;
                     end if;
                  elsif ID = 'N' then
                     if iloscPomidora >= 1 then
                        iloscPomidora := iloscPomidora - 1;
                        iloscNapojow := iloscNapojow + 1;
                        put_line("Przygotowano 1 napoj");
                     else
                        put_line("BRAK SKLADNIKOW DO PRODUKCJI NAPOJOW!");
                        brakSkladnika;
                     end if;
                  elsif ID = 'D' then
                     if iloscCiasta >= 1 then
                        iloscCiasta := iloscCiasta - 1;
                        iloscDeserow := iloscDeserow + 1;
                        put_line("Przygotowano 1 deser");
                     else
                        put_line("BRAK SKLADNIKOW DO PRODUKCJI DESEROW!");
                        brakSkladnika;
                     end if;
                  end if;
               else
                  put_line("NIE MOZNA PRODUKOWAC, SKONCZYLO SIE MIEJSCE W MAGAZYNIE!");
               end if;
            end produkcja;
         end select;
         
         losWypisu := LosowanieWypisuStanu.Random(losowacz);
         if losWypisu = 0 then
            wypiszStanMagazynu;
         end if;
         
         begin
            brakSkladnika;
         exception
            when wyjatek : Wyjatki.brakSkladnika =>
               New_Line;
               put_line(Ada.Exceptions.Exception_Message(wyjatek));
               New_Line;
               iloscMaki := 0;
               iloscPomidora := 0;
               iloscSeru := 0;
               iloscCiasta := 0;     
               iloscPizzy := 0;
               iloscNapojow := 0;
               iloscDeserow := 0;               
               iloscNieudanychWstawien := 0;
               wypiszStanMagazynu;
         end;
         
      end loop; 
   end Rachunek;      
begin  
  null;  
end simulation;
