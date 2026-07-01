String weatherDescriptionFromCode(int code) {
  switch (code) {
    case 0:
      return 'Klarer Himmel';
    case 1:
      return 'Überwiegend klar';
    case 2:
      return 'Teilweise bewölkt';
    case 3:
      return 'Bewölkt';
    case 45:
    case 48:
      return 'Nebel';
    case 51:
    case 53:
    case 55:
      return 'Nieselregen';
    case 61:
    case 63:
    case 65:
      return 'Regen';
    case 66:
    case 67:
      return 'Gefrierender Regen';
    case 71:
    case 73:
    case 75:
      return 'Schneefall';
    case 77:
      return 'Schneegriesel';
    case 80:
    case 81:
    case 82:
      return 'Regenschauer';
    case 85:
    case 86:
      return 'Schneeschauer';
    case 95:
      return 'Gewitter';
    case 96:
    case 99:
      return 'Gewitter mit Hagel';
    default:
      return 'Unbekannt';
  }
}
