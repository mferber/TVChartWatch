import SwiftUI

struct EpisodeDetails: View {
  let text: String

  var body: some View {
    Text(text).navigationTitle(text)
  }
}
