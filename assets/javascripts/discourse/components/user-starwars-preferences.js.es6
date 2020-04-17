import 'discourse/models/store'
import { default as computed, on } from 'ember-addons/ember-computed-decorators';
import { ajax } from 'discourse/lib/ajax';

export default Ember.Component.extend({
  layoutName: 'javascripts/discourse/templates/connectors/user-custom-preferences/user-starwars-preferences',

  @computed('model.custom_fields.starwars_iso')
  flagsource() {
    return  (this.get('model.custom_fields.starwars_iso')==null) ? 'none' : this.get('model.custom_fields.starwars_iso')
  }
});
