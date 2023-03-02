import { LightningElement, api } from 'lwc';

/** Static Resources. */
import BIKE_ASSETS_URL from '@salesforce/resourceUrl/bike_assets';

export default class Placeholder extends LightningElement {
    @api message;

    /** Url for bike logo. */
    logoUrl = `${BIKE_ASSETS_URL}/logo.svg`;
}