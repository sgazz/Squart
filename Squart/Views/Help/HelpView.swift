import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Glavni naslov
                    Text("Kako igrati Squart")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                    
                    // Osnovni opis igre
                    Group {
                        Text("O igri")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Squart je logička igra za dva igrača inspirisana igrom TicTacToe, ali sa izmenjenim pravilima. Cilj igre je da ostavite protivnika bez validnih poteza.")
                            .padding(.bottom, 8)
                            
                        Text("Na tabli se nalaze bela (prazna) i crna (blokirana) polja. Crna polja se ne mogu koristiti za igru.")
                            .padding(.bottom, 8)
                    }
                    
                    // Pravila igre
                    Group {
                        Text("Pravila igre")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("• Plavi igrač igra prvi u prvoj partiji, a zatim se naizmenično menja ko igra prvi")
                            .padding(.bottom, 4)
                        
                        Text("• Plavi igrač postavlja plave žetone horizontalno - kada klikne na prazno polje, žeton zauzima to polje i polje desno od njega")
                            .padding(.bottom, 4)
                        
                        Text("• Crveni igrač postavlja crvene žetone vertikalno - kada klikne na prazno polje, žeton zauzima to polje i polje ispod njega")
                            .padding(.bottom, 4)
                        
                        Text("• Igrači se naizmenično smenjuju")
                            .padding(.bottom, 4)
                        
                        Text("• Nije dozvoljeno postavljanje žetona na crna polja ili polja koja su već zauzeta")
                            .padding(.bottom, 4)
                        
                        Text("• Potez je validan samo ako ima dovoljno prostora za ceo žeton (dva polja)")
                            .padding(.bottom, 4)
                        
                        Text("• Svaki igrač ima ograničeno vreme za celu partiju (kao u šahu). Vreme se meri samo dok je igrač na potezu.")
                            .padding(.bottom, 4)
                    }
                    
                    // Kako pobediti
                    Group {
                        Text("Kako pobediti")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Igru možete pobediti na dva načina:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.bottom, 4)
                        
                        Text("1. Dovesti protivnika u situaciju da ne može da odigra validan potez. Pobednik je igrač koji je odigrao poslednji validni potez.")
                            .padding(.bottom, 4)
                        
                        Text("2. Kada protivniku istekne vreme. Ako igraču istekne vreme na njegovom satu, protivnik je pobednik.")
                            .padding(.bottom, 4)
                    }
                    
                    // AI protivnik
                    Group {
                        Text("AI protivnik")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Pored igre protiv drugog igrača, možete igrati i protiv računara (AI):")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.bottom, 4)
                        
                        Text("• AI opciju možete uključiti u podešavanjima")
                            .padding(.bottom, 4)
                        
                        Text("• Možete izabrati da AI igra kao plavi ili crveni tim")
                            .padding(.bottom, 4)
                        
                        Text("• Dostupna su tri nivoa težine: Lako, Srednje i Teško")
                            .padding(.bottom, 4)
                        
                        Text("• Prvi igrač se naizmenično menja nakon svake partije")
                            .padding(.bottom, 4)
                        
                        Text("• Kada je AI na potezu, ne možete vi odigrati njegov potez")
                            .padding(.bottom, 4)
                        
                        Text("• AI vs AI mod: Možete aktivirati i opciju da dva AI igrača igraju jedan protiv drugog")
                            .padding(.bottom, 4)
                            
                        Text("• U AI vs AI modu, možete izabrati težinu za svakog od AI igrača posebno")
                            .padding(.bottom, 4)
                            
                        Text("• AI vs AI mod je koristan za učenje strategije i tehnika igre")
                            .padding(.bottom, 4)
                    }
                    
                    // Saveti za igru
                    Group {
                        Text("Saveti za igru")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("• Planirajte unapred - razmišljajte o tome kako će vaš potez uticati na moguće poteze protivnika")
                            .padding(.bottom, 4)
                        
                        Text("• Pokušajte da protivniku blokirate prostor za postavljanje njegovog žetona")
                            .padding(.bottom, 4)
                        
                        Text("• Često je bolje igrati na ivicama table nego u sredini, posebno u ranim fazama igre")
                            .padding(.bottom, 4)
                        
                        Text("• Obratite pažnju na crna polja - ona mogu biti korisna ili štetna za vašu strategiju")
                            .padding(.bottom, 4)
                    }
                }
                .padding()
                .foregroundColor(.white)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.2, blue: 0.45),
                        Color(red: 0.3, green: 0.4, blue: 0.6),
                        Color(red: 0.5, green: 0.2, blue: 0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
            .navigationBarTitle("help".localized, displayMode: .inline)
            .navigationBarItems(trailing: Button("close".localized) {
                dismiss()
            })
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    HelpView()
} 